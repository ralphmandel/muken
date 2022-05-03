item_rare_wild_axe_mod_passive = class({})

function item_rare_wild_axe_mod_passive:IsHidden()
    return true
end

function item_rare_wild_axe_mod_passive:IsPurgable()
    return false
end

---------------------------------------------------------------------------------------------------

function item_rare_wild_axe_mod_passive:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local passive_str = self.ability:GetSpecialValueFor("passive_str")
	local passive_dex = self.ability:GetSpecialValueFor("passive_dex")

	self.ability:AddBonus("_1_STR", self.parent, passive_str, 0, nil)
	self.ability:AddBonus("_2_DEX", self.parent, passive_dex, 0, nil)
end

function item_rare_wild_axe_mod_passive:OnRefresh( kv )
end

function item_rare_wild_axe_mod_passive:OnRemoved( kv )
	self.ability:RemoveBonus("_1_STR", self.parent)
	self.ability:RemoveBonus("_2_DEX", self.parent)
end