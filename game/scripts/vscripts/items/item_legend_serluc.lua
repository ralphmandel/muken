item_legend_serluc = class({})
LinkLuaModifier("item_legend_serluc_mod_passive", "items/item_legend_serluc_mod_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("item_legend_serluc_mod_berserk", "items/item_legend_serluc_mod_berserk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

function item_legend_serluc:CalcStatus(duration, caster, target)
	if caster == nil or target == nil then return duration end
	if IsValidEntity(caster) == false or IsValidEntity(target) == false then return duration end
	local base_stats = caster:FindAbilityByName("base_stats")

	if caster:GetTeamNumber() == target:GetTeamNumber() then
		if base_stats then duration = duration * (1 + base_stats:GetBuffAmp()) end
	else
		if base_stats then duration = duration * (1 + base_stats:GetDebuffAmp()) end
		duration = duration * (1 - target:GetStatusResistance())
	end
	
	return duration
end

function item_legend_serluc:AddBonus(string, target, const, percent, time)
	local base_stats = target:FindAbilityByName("base_stats")
	if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
end

function item_legend_serluc:RemoveBonus(string, target)
	local stringFormat = string.format("%s_modifier_stack", string)
	local mod = target:FindAllModifiersByName(stringFormat)
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self then modifier:Destroy() end
	end
end

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
		duration = self:CalcStatus(duration, caster, nil)
	})
end