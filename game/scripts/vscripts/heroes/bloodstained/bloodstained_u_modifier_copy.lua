bloodstained_u_modifier_copy = class({})

--------------------------------------------------------------------------------

function bloodstained_u_modifier_copy:IsHidden()
	return true
end

function bloodstained_u_modifier_copy:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function bloodstained_u_modifier_copy:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.target = self.parent:GetForceAttackTarget()

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, nil, "bloodstained_u_modifier_copy_status_efx", true) end
end

function bloodstained_u_modifier_copy:OnRefresh(kv)
end

function bloodstained_u_modifier_copy:OnRemoved(kv)
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, nil, "bloodstained_u_modifier_copy_status_efx", false) end

	if self.target ~= nil then
		if IsValidEntity(self.target) then
			self.target:RemoveModifierByNameAndCaster("bloodstained_u_modifier_debuff_slow", self.caster)
		end
	end
end

--------------------------------------------------------------------------------

function bloodstained_u_modifier_copy:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
        [MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
	}

	return state
end

function bloodstained_u_modifier_copy:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_DISABLE_HEALING
	}
	
	return funcs
end

function bloodstained_u_modifier_copy:GetModifierMoveSpeedBonus_Percentage(target)
	return 100
end

function bloodstained_u_modifier_copy:GetDisableHealing()
	return 1
end

------------------------------------------------------------------------------------

function bloodstained_u_modifier_copy:GetStatusEffectName()
	return "particles/bloodstained/bloodstained_u_illusion_status.vpcf"
end

function bloodstained_u_modifier_copy:StatusEffectPriority()
	return 99999999
end

function bloodstained_u_modifier_copy:GetEffectName()
	return "particles/units/heroes/hero_bloodseeker/bloodseeker_rupture.vpcf"
end

-- function bloodstained_u_modifier_copy:PlayEffects()

-- 	local particle_cast = "particles/econ/items/bloodseeker/bloodseeker_ti7/bloodseeker_ti7_ambient_trail_pnt.vpcf"
-- 	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent )

-- 	ParticleManager:SetParticleControlEnt(
-- 		effect_cast,
-- 		1,
-- 		self.parent,
-- 		PATTACH_ABSORIGIN_FOLLOW,
-- 		"",
-- 		Vector(0,0,0), -- unknown
-- 		true -- unknown, true
-- 	)

-- 	self:AddParticle(
-- 		effect_cast,
-- 		false, -- bDestroyImmediately
-- 		false, -- bStatusEffect
-- 		-1, -- iPriority
-- 		false, -- bHeroEffect
-- 		false -- bOverheadEffect
-- 	)
-- end