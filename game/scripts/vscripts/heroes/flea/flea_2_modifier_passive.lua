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
		return self:GetAbility():GetSpecialValueFor("min_speed")
	end
end

function flea_2_modifier_passive:GetModifierConstantHealthRegen()
	if IsServer() then
		local min_speed = self:GetAbility():GetSpecialValueFor("min_speed")
		local regen = self:GetAbility():GetSpecialValueFor("regen") * 0.01
		return (self:GetParent():GetIdealSpeed() - min_speed - 50) * regen
	end
end

function flea_2_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end

	local duration = self.ability:GetSpecialValueFor("duration")

	self.parent:AddNewModifier(self.caster, self.ability, "flea_2_modifier_speed", {
		duration = self.ability:CalcStatus(duration, self.caster, self.parent)
	})
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------