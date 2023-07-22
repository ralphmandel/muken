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
	local passive_con = self.ability:GetSpecialValueFor("passive_con")

	AddBonus(self.ability, "STR", self.parent, passive_str, 0, nil)
	AddBonus(self.ability, "CON", self.parent, passive_con, 0, nil)
end

function item_rare_wild_axe_mod_passive:OnRefresh( kv )
end

function item_rare_wild_axe_mod_passive:OnRemoved( kv )
	RemoveBonus(self.ability, "STR", self.parent)
	RemoveBonus(self.ability, "CON", self.parent)
end