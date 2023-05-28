item_legend_serluc = class({})
LinkLuaModifier("item_legend_serluc_mod_passive", "items/item_legend_serluc_mod_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("item_legend_serluc_mod_berserk", "items/item_legend_serluc_mod_berserk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "_modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

function item_legend_serluc:OnUpgrade()
	if self:GetLevel() < self:GetMaxLevel() then
		if self.xp == nil then self.xp = 0 end
		self.xp = self:GetSpecialValueFor("xp") - self.xp
	end
end

function item_legend_serluc:CheckXP()
	if self.xp == nil then self.xp = self:GetSpecialValueFor("xp") end
end

-----------------------------------------------------------

function item_legend_serluc:GetIntrinsicModifierName()
	return "item_legend_serluc_mod_passive"
end

function item_legend_serluc:OnSpellStart()
	local caster = self:GetCaster()
	local duration = self:GetSpecialValueFor("duration")

	if IsServer() then caster:EmitSound("DOTA_Item.MaskOfMadness.Activate") end

	caster:AddNewModifier(caster, self, "item_legend_serluc_mod_berserk", {
		duration = CalcStatus(duration, caster, nil)
	})
end