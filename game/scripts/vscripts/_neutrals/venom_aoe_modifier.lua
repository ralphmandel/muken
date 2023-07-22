venom_aoe_modifier = class({})

function venom_aoe_modifier:IsHidden()
	return false
end

function venom_aoe_modifier:IsPurgable()
	return false
end

function venom_aoe_modifier:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function venom_aoe_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.radius = self.ability:GetSpecialValueFor("radius")
	local def_reduction = self.ability:GetSpecialValueFor("def_reduction")
	local damage = self.ability:GetSpecialValueFor("damage")

	self.thinker = kv.isProvidedByAura~=1

	if not self.thinker then
		AddBonus(self.ability, "DEF", self.parent, -def_reduction, 0, nil)

		self.damageTable = {
			victim = self.parent,
			attacker = self.caster,
			damage = damage,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self.ability
		}
	
		self:StartIntervalThink(1)		
	else
		self:PlayEfxStart()
	end
end

function venom_aoe_modifier:OnRefresh( kv )
end

function venom_aoe_modifier:OnRemoved()
	if not self.thinker then
		RemoveBonus(self.ability, "DEF", self.parent)	
	else
		if IsServer() then self.parent:StopSound("Hero_Alchemist.AcidSpray") end
	end
end

function venom_aoe_modifier:OnDestroy()
	if not self.thinker then return end
	UTIL_Remove(self.parent)
end

--------------------------------------------------------------------------------

function venom_aoe_modifier:OnIntervalThink()
	self:PlayEfxSound(self.parent)
	ApplyDamage(self.damageTable)
end

--------------------------------------------------------------------------------

-- Aura Effects
function venom_aoe_modifier:IsAura()
	return self.thinker
end

function venom_aoe_modifier:GetModifierAura()
	return "venom_aoe_modifier"
end

function venom_aoe_modifier:GetAuraRadius()
	return self.radius
end

function venom_aoe_modifier:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function venom_aoe_modifier:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function venom_aoe_modifier:GetAuraSearchFlags()
	return 0
end

--------------------------------------------------------------------------------

function venom_aoe_modifier:GetEffectName()
	return "particles/units/heroes/hero_alchemist/alchemist_acid_spray_debuff.vpcf"
end

function venom_aoe_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function venom_aoe_modifier:PlayEfxStart()
	local particle_cast = "particles/units/heroes/hero_alchemist/alchemist_acid_spray.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )
	ParticleManager:SetParticleControl( effect_cast, 0, self.parent:GetOrigin() )
	ParticleManager:SetParticleControl( effect_cast, 1, Vector( self.radius, 1, 1 ) )
	self:AddParticle(effect_cast, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_Alchemist.AcidSpray") end
end

function venom_aoe_modifier:PlayEfxSound(target)
	if IsServer() then target:EmitSound("Hero_Alchemist.AcidSpray.Damage") end
end