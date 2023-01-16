icebreaker__modifier_frozen = class({})

function icebreaker__modifier_frozen:IsHidden() return false end
function icebreaker__modifier_frozen:IsPurgable() return false end
function icebreaker__modifier_frozen:GetPriority() return MODIFIER_PRIORITY_HIGH end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker__modifier_frozen:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	self.damageTable = {
		victim = self.parent, attacker = self.caster,
		damage = 100, damage_type = DAMAGE_TYPE_MAGICAL,
		ability = nil
	}

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "icebreaker__modifier_frozen_status_efx", true) end

	self.parent:RemoveModifierByNameAndCaster("icebreaker__modifier_hypo", self.caster)

	if IsServer() then self:PlayEfxStart() end
end

function icebreaker__modifier_frozen:OnRefresh(kv)
end

function icebreaker__modifier_frozen:OnRemoved()
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "icebreaker__modifier_frozen_status_efx", false) end

	ApplyDamage(self.damageTable)

	if IsServer() then self:PlayEfxDestroy() end
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker__modifier_frozen:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
		[MODIFIER_STATE_FROZEN] = true,
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
		[MODIFIER_STATE_INVISIBLE] = false,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NO_TEAM_SELECT] = true
	}

	return state
end

function icebreaker__modifier_frozen:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_STATE_CHANGED,
		MODIFIER_PROPERTY_AVOID_DAMAGE
	}

	return funcs
end

function icebreaker__modifier_frozen:OnStateChanged(keys)
	if keys.unit ~= self.parent then return end
	if self.parent:IsStunned() == false then self:Destroy() end
end

function icebreaker__modifier_frozen:GetModifierAvoidDamage(keys)
	if keys.target ~= self.parent then return 0 end
	if keys.damage <= 0 then return 0 end

	self:PlayEfxHit()

	if self:GetElapsedTime() >= 2 then
		self:Destroy()
	end

	return 1
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function icebreaker__modifier_frozen:GetEffectName()
	return "particles/econ/items/winter_wyvern/winter_wyvern_ti7/wyvern_cold_embrace_ti7buff.vpcf"
end

function icebreaker__modifier_frozen:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function icebreaker__modifier_frozen:GetStatusEffectName()
	return "particles/econ/items/drow/drow_ti9_immortal/status_effect_drow_ti9_frost_arrow.vpcf"
end

function icebreaker__modifier_frozen:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end

function icebreaker__modifier_frozen:PlayEfxStart()
	if IsServer() then self.parent:EmitSound("Hero_Ancient_Apparition.IceBlast.Tracker") end
end

function icebreaker__modifier_frozen:PlayEfxHit()
	if IsServer() then self.parent:EmitSound("Hero_Lich.ProjectileImpact") end
end

function icebreaker__modifier_frozen:PlayEfxDestroy()
	local particle = "particles/units/heroes/hero_winter_wyvern/wyvern_arctic_burn_start.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())

	local particle_2 = "particles/econ/items/crystal_maiden/crystal_maiden_maiden_of_icewrack/cm_arcana_pup_flee.vpcf"
	local effect_cast_2 = ParticleManager:CreateParticle(particle_2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast_2, 0, self.parent:GetOrigin())

	if IsServer() then self.parent:EmitSound("Hero_Lich.IceSpire.Destroy") end
end