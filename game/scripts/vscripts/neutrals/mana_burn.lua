mana_burn = class({})
LinkLuaModifier("mana_burn_modifier", "neutrals/mana_burn_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

function mana_burn:CalcStatus(duration, caster, target)
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

function mana_burn:GetIntrinsicModifierName()
	return "mana_burn_modifier"
end