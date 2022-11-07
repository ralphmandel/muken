flea_u_modifier_target = class({})

function flea_u_modifier_target:IsHidden()
	return false
end

function flea_u_modifier_target:IsPurgable()
	return true
end

function flea_u_modifier_target:IsDebuff()
	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_u_modifier_target:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:SetStackCount(1) end
end

function flea_u_modifier_target:OnRefresh(kv)
	if IsServer() then self:IncrementStackCount() end
end

function flea_u_modifier_target:OnRemoved()
	local caster_mod = self.caster:FindModifierByNameAndCaster("flea_u_modifier_caster", self.caster)
	if caster_mod then caster_mod:SetStackCount(caster_mod:GetStackCount() - self:GetStackCount()) end
	
	self.ability:RemoveBonus("_1_STR", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_u_modifier_target:OnStackCountChanged(old)
	if self:GetStackCount() == 0 then return end

	self.ability:RemoveBonus("_1_STR", self.parent)
	self.ability:AddBonus("_1_STR", self.parent, -self:GetStackCount(), 0, nil)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------