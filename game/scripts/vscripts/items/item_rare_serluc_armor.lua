item_rare_serluc_armor = class({})
LinkLuaModifier("item_rare_serluc_armor_mod_aura", "items/item_rare_serluc_armor_mod_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("item_rare_serluc_armor_mod_effect", "items/item_rare_serluc_armor_mod_effect", LUA_MODIFIER_MOTION_NONE)

function item_rare_serluc_armor:CalcStatus(duration, caster, target)
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

function item_rare_serluc_armor:AddBonus(string, target, const, percent, time)
	local base_stats = target:FindAbilityByName("base_stats")
	if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
end

function item_rare_serluc_armor:RemoveBonus(string, target)
	local stringFormat = string.format("%s_modifier_stack", string)
	local mod = target:FindAllModifiersByName(stringFormat)
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self then modifier:Destroy() end
	end
end

-----------------------------------------------------------

function item_rare_serluc_armor:GetIntrinsicModifierName()
	return "item_rare_serluc_armor_mod_aura"
end