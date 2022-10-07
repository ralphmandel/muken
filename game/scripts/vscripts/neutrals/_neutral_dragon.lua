_neutral_dragon = class({})
LinkLuaModifier( "_modifier_neutral_dragon", "neutrals/_modifier_neutral_dragon", LUA_MODIFIER_MOTION_NONE )

function _neutral_dragon:CalcStatus(duration, caster, target)
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

function _neutral_dragon:GetIntrinsicModifierName()
	return "_modifier_neutral_dragon"
end