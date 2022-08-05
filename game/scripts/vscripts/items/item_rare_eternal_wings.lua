item_rare_eternal_wings = class({})
LinkLuaModifier("item_rare_eternal_wings_mod_passive", "items/item_rare_eternal_wings_mod_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("item_rare_eternal_wings_mod_buff", "items/item_rare_eternal_wings_mod_buff", LUA_MODIFIER_MOTION_NONE)

function item_rare_eternal_wings:CalcStatus(duration, caster, target)
    if caster == nil or target == nil then return end
    if IsValidEntity(caster) == false or IsValidEntity(target) == false then return end
    local base_stats = caster:FindAbilityByName("base_stats")

    if caster:GetTeamNumber() == target:GetTeamNumber() then
        if base_stats then duration = duration * (1 + base_stats:GetBuffAmp()) end
    else
        if base_stats then duration = duration * (1 + base_stats:GetDebuffAmp()) end
        duration = duration * (1 - target:GetStatusResistance())
    end
    
    return duration
end

function item_rare_eternal_wings:AddBonus(string, target, const, percent, time)
	local base_stats = target:FindAbilityByName("base_stats")
	if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
end

function item_rare_eternal_wings:RemoveBonus(string, target)
	local stringFormat = string.format("%s_modifier_stack", string)
	local mod = target:FindAllModifiersByName(stringFormat)
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self then modifier:Destroy() end
	end
end

-----------------------------------------------------------

function item_rare_eternal_wings:GetIntrinsicModifierName()
	return "item_rare_eternal_wings_mod_passive"
end