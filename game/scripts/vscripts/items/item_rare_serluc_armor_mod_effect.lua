item_rare_serluc_armor_mod_effect = class({})

function item_rare_serluc_armor_mod_effect:IsHidden()
    return false
end

function item_rare_serluc_armor_mod_effect:IsPurgable()
    return false
end

---------------------------------------------------------------------------------------------------

function item_rare_serluc_armor_mod_effect:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local def = self.ability:GetSpecialValueFor("def")
	local res = self.ability:GetSpecialValueFor("res")

	self.ability:AddBonus("_2_DEF", self.parent, def, 0, nil)
	self.ability:AddBonus("_2_RES", self.parent, res, 0, nil)
end

function item_rare_serluc_armor_mod_effect:OnRefresh( kv )
end

function item_rare_serluc_armor_mod_effect:OnRemoved( kv )
	self.ability:RemoveBonus("_2_DEF", self.parent)
	self.ability:RemoveBonus("_2_RES", self.parent)
end