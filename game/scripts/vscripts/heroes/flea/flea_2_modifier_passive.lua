flea_2_modifier_passive = class({})

function flea_2_modifier_passive:IsHidden()
	return true
end

function flea_2_modifier_passive:IsPurgable()
	return false
end

function flea_2_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_2_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function flea_2_modifier_passive:OnRefresh(kv)
end

function flea_2_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_2_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function flea_2_modifier_passive:GetModifierMoveSpeed_AbsoluteMin()
	if IsServer() then
		if self:GetParent():PassivesDisabled() == false then
			local min_speed = self:GetAbility():GetSpecialValueFor("min_speed")
			if self:GetAbility():GetCurrentAbilityCharges() % 2 == 0 then min_speed = min_speed + 75 end
			return min_speed
		end

		return 0
	end
end

function flea_2_modifier_passive:GetModifierConstantHealthRegen()
	if IsServer() then
		if self:GetParent():PassivesDisabled() == false then
			local min_speed = self:GetAbility():GetSpecialValueFor("min_speed")
			local regen = self:GetAbility():GetSpecialValueFor("regen") * 0.01
			if self:GetAbility():GetCurrentAbilityCharges() % 3 == 0 then regen = regen * 1.5 end
			return (self:GetParent():GetIdealSpeed() - min_speed - 50) * regen
		end

		return 0
	end
end

function flea_2_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self.parent:PassivesDisabled() then return end

	local duration = self.ability:GetSpecialValueFor("duration")

	-- UP 2.31
	if self.ability:GetRank(31) then
		duration = duration + 4
	end

	self.parent:AddNewModifier(self.caster, self.ability, "flea_2_modifier_speed", {
		duration = self.ability:CalcStatus(duration, self.caster, self.parent)
	})
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------