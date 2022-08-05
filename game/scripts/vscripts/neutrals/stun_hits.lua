stun_hits = class({})
LinkLuaModifier( "stun_hits_modifier", "neutrals/stun_hits_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

function stun_hits:CalcStatus(duration, caster, target)
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

function stun_hits:GetIntrinsicModifierName()
	return "stun_hits_modifier"
end