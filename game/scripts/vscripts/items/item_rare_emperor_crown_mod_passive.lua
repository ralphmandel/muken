item_rare_emperor_crown_mod_passive = class({})

function item_rare_emperor_crown_mod_passive:IsHidden()
    return true
end

function item_rare_emperor_crown_mod_passive:IsPurgable()
    return false
end

---------------------------------------------------------------------------------------------------

function item_rare_emperor_crown_mod_passive:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local passive_str = self.ability:GetSpecialValueFor("passive_str")
	local passive_agi = self.ability:GetSpecialValueFor("passive_agi")
	local passive_con = self.ability:GetSpecialValueFor("passive_con")
	local passive_int = self.ability:GetSpecialValueFor("passive_int")
	local passive_mnd = self.ability:GetSpecialValueFor("passive_mnd")
	local passive_lck = self.ability:GetSpecialValueFor("passive_lck")
	local passive_def = self.ability:GetSpecialValueFor("passive_def")
	local passive_dex = self.ability:GetSpecialValueFor("passive_dex")
	local passive_res = self.ability:GetSpecialValueFor("passive_res")
	local passive_rec = self.ability:GetSpecialValueFor("passive_rec")
	

	AddBonus(self.ability, "STR", self.parent, passive_str, 0, nil)
	AddBonus(self.ability, "AGI", self.parent, passive_agi, 0, nil)
	AddBonus(self.ability, "CON", self.parent, passive_con, 0, nil)
	AddBonus(self.ability, "INT", self.parent, passive_int, 0, nil)
	AddBonus(self.ability, "MND", self.parent, passive_mnd, 0, nil)
	AddBonus(self.ability, "LCK", self.parent, passive_lck, 0, nil)
	AddBonus(self.ability, "DEF", self.parent, passive_def, 0, nil)
	AddBonus(self.ability, "DEX", self.parent, passive_dex, 0, nil)
	AddBonus(self.ability, "RES", self.parent, passive_res, 0, nil)
	AddBonus(self.ability, "REC", self.parent, passive_rec, 0, nil)

end

function item_rare_emperor_crown_mod_passive:OnRefresh( kv )
end

function item_rare_emperor_crown_mod_passive:OnRemoved( kv )
	RemoveBonus(self.ability, "STR", self.parent)
	RemoveBonus(self.ability, "AGI", self.parent)
	RemoveBonus(self.ability, "CON", self.parent)
	RemoveBonus(self.ability, "INT", self.parent)
	RemoveBonus(self.ability, "MND", self.parent)
	RemoveBonus(self.ability, "LCK", self.parent)
	RemoveBonus(self.ability, "DEF", self.parent)
	RemoveBonus(self.ability, "DEX", self.parent)
	RemoveBonus(self.ability, "RES", self.parent)
	RemoveBonus(self.ability, "REC", self.parent)
end