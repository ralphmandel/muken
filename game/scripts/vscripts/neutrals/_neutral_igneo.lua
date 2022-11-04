_neutral_igneo = class({})
LinkLuaModifier( "_modifier_neutral_igneo", "neutrals/_modifier_neutral_igneo", LUA_MODIFIER_MOTION_NONE )

function _neutral_igneo:CalcStatus(duration, caster, target)
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

function _neutral_igneo:GetIntrinsicModifierName()
	return "_modifier_neutral_igneo"
end