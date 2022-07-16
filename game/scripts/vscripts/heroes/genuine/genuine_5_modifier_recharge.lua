genuine_5_modifier_recharge = class({})

function genuine_5_modifier_recharge:IsHidden()
	return false
end

function genuine_5_modifier_recharge:IsPurgable()
	return false
end

function genuine_5_modifier_recharge:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_5_modifier_recharge:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function genuine_5_modifier_recharge:OnRefresh(kv)
end

function genuine_5_modifier_recharge:OnRemoved()
    self.parent:FindModifierByName(self.ability:GetIntrinsicModifierName()):SetStackCount(self.ability.charges)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------