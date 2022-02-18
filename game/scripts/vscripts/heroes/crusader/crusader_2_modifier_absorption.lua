crusader_2_modifier_absorption = class({})

function crusader_2_modifier_absorption:IsHidden()
	return false
end

function crusader_2_modifier_absorption:IsPurgable()
    return true
end

-----------------------------------------------------------

function crusader_2_modifier_absorption:OnCreated( kv )
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self:PlayEfxStart()
	self:StartIntervalThink(0.1)
end

function crusader_2_modifier_absorption:OnRefresh( kv )
end

function crusader_2_modifier_absorption:OnRemoved()
end

----------------------------------------------------------------------

function crusader_2_modifier_absorption:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
	}

	return funcs
end

function crusader_2_modifier_absorption:GetModifierIncomingDamage_Percentage(keys)

	local damage = keys.original_damage * 0.5
	local attacker = keys.attacker
	local damage_type = keys.damage_type

	if keys.damage_flags == DOTA_DAMAGE_FLAG_REFLECTION then return end

	local damageTable = {
		victim = self.caster,
		attacker = attacker,
		damage = damage,
		damage_type = damage_type,
		ability = self.ability,
		damage_flags = DOTA_DAMAGE_FLAG_REFLECTION,
	}
	ApplyDamage(damageTable)

	local projectile_name = "particles/units/heroes/hero_rubick/rubick_spell_steal.vpcf"
	local projectile_speed = 1000

	local info = {
		Target = self.caster,
		Source = self.parent,
		Ability = self.ability,	
		EffectName = projectile_name,
		iMoveSpeed = projectile_speed,
		vSourceLoc = self.parent:GetAbsOrigin(),
		bDrawsOnMinimap = false,
		bDodgeable = false,
		bVisibleToEnemies = true,
		bReplaceExisting = false,
	}

	ProjectileManager:CreateTrackingProjectile(info)
    self:PlayEfxSound()

	return -50
end

function crusader_2_modifier_absorption:OnIntervalThink()
	if self.caster:HasModifier("crusader_2_modifier_shield") == false then
		self:Destroy()
	end
end

-----------------------------------------------------------

function crusader_2_modifier_absorption:PlayEfxSound()
	if IsServer() then self.caster:EmitSound("Hero_Dark_Seer.Ion_Shield_end") end
end

function crusader_2_modifier_absorption:PlayEfxStart()
	local particle_cast2 = "particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell_fear_debuff.vpcf"
	local effect_cast2 = ParticleManager:CreateParticle( particle_cast2, PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
	self:AddParticle(
		effect_cast2,
		false, -- bDestroyImmediately
		false, -- bStatusEffect
		-1, -- iPriority
		false, -- bHeroEffect
		false -- bOverheadEffect
	)
end