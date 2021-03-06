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
	

	self.ability:AddBonus("_1_STR", self.parent, passive_str, 0, nil)
	self.ability:AddBonus("_1_AGI", self.parent, passive_agi, 0, nil)
	self.ability:AddBonus("_1_CON", self.parent, passive_con, 0, nil)
	self.ability:AddBonus("_1_INT", self.parent, passive_int, 0, nil)
	self.ability:AddBonus("_2_MND", self.parent, passive_mnd, 0, nil)
	self.ability:AddBonus("_2_LCK", self.parent, passive_lck, 0, nil)
	self.ability:AddBonus("_2_DEF", self.parent, passive_def, 0, nil)
	self.ability:AddBonus("_2_DEX", self.parent, passive_dex, 0, nil)
	self.ability:AddBonus("_2_RES", self.parent, passive_res, 0, nil)
	self.ability:AddBonus("_2_REC", self.parent, passive_rec, 0, nil)

end

function item_rare_emperor_crown_mod_passive:OnRefresh( kv )
end

function item_rare_emperor_crown_mod_passive:OnRemoved( kv )
	self.ability:RemoveBonus("_1_STR", self.parent)
	self.ability:RemoveBonus("_1_AGI", self.parent)
	self.ability:RemoveBonus("_1_CON", self.parent)
	self.ability:RemoveBonus("_1_INT", self.parent)
	self.ability:RemoveBonus("_2_MND", self.parent)
	self.ability:RemoveBonus("_2_LCK", self.parent)
	self.ability:RemoveBonus("_2_DEF", self.parent)
	self.ability:RemoveBonus("_2_DEX", self.parent)
	self.ability:RemoveBonus("_2_RES", self.parent)
	self.ability:RemoveBonus("_2_REC", self.parent)
end