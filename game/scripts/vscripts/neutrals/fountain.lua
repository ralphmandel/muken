fountain = class({})
LinkLuaModifier( "fountain_modifier", "neutrals/fountain_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("_modifier_truesight", "modifiers/_modifier_truesight", LUA_MODIFIER_MOTION_NONE)

function fountain:CalcStatus(duration, caster, target)
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

function fountain:GetIntrinsicModifierName()
	return "fountain_modifier"
end

-- function fountain:Spawn()
--     local caster = self:GetCaster()
--     CreateModifierThinker(caster, self, "fountain_modifier", {}, caster:GetOrigin(), caster:GetTeamNumber(), false)
-- end