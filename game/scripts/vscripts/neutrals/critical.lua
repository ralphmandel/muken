critical = class({})
LinkLuaModifier( "critical_modifier", "neutrals/critical_modifier", LUA_MODIFIER_MOTION_NONE )

function critical:CalcStatus(duration, caster, target)
    local time = duration
    if caster == nil then return time end
    local caster_int = caster:FindModifierByName("_1_INT_modifier")
    local caster_mnd = caster:FindModifierByName("_2_MND_modifier")

    if target == nil then
        if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
    else
        if caster:GetTeamNumber() == target:GetTeamNumber() then
            if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
        else
            local target_res = target:FindModifierByName("_2_RES_modifier")
            if caster_int then time = duration * (1 + caster_int:GetDebuffTime()) end
            if target_res then time = time * (1 - target_res:GetStatus()) end
        end
    end

    if time < 0 then time = 0 end
    return time
end

function critical:GetIntrinsicModifierName()
	return "critical_modifier"
end