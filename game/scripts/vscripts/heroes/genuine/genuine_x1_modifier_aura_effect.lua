genuine_x1_modifier_aura_effect = class({})

function genuine_x1_modifier_aura_effect:IsHidden()
	return false
end

function genuine_x1_modifier_aura_effect:IsPurgable()
	return false
end

-----------------------------------------------------------

function genuine_x1_modifier_aura_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local res = self.ability:GetSpecialValueFor("res")
	self.ability:AddBonus("_2_DEF", self.parent, res, 0, nil)
end

function genuine_x1_modifier_aura_effect:OnRefresh(kv)
end

function genuine_x1_modifier_aura_effect:OnRemoved(kv)
	self.ability:RemoveBonus("_2_RES", self.parent)
end