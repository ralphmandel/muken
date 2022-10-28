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
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
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