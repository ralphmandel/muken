_neutral_skydragon = class({})
LinkLuaModifier( "_modifier_neutral_skydragon", "neutrals/_modifier_neutral_skydragon", LUA_MODIFIER_MOTION_NONE )

function _neutral_skydragon:CalcStatus(duration, caster, target)
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

function _neutral_skydragon:GetIntrinsicModifierName()
	return "_modifier_neutral_skydragon"
end