flea_u_modifier_caster = class({})

function flea_u_modifier_caster:IsHidden()
	return false
end

function flea_u_modifier_caster:IsPurgable()
	return false
end

function flea_u_modifier_caster:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_u_modifier_caster:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:SetStackCount(1) end
end

function flea_u_modifier_caster:OnRefresh(kv)
	if IsServer() then self:IncrementStackCount() end
end

function flea_u_modifier_caster:OnRemoved()
	RemoveBonus(self.ability, "_1_STR", self.parent)
	self.parent:FindModifierByNameAndCaster(self.ability:GetIntrinsicModifierName(), self.caster):RemoveAllTargets()
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_u_modifier_caster:OnStackCountChanged(old)
	if self:GetStackCount() == 0 then self:Destroy() return end

	RemoveBonus(self.ability, "_1_STR", self.parent)
	AddBonus(self.ability, "_1_STR", self.parent, self:GetStackCount(), 0, nil)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------