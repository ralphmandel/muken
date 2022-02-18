strider_x1__seal = class({})
LinkLuaModifier( "strider_x1_modifier_seal", "heroes/strider/strider_x1_modifier_seal", LUA_MODIFIER_MOTION_NONE )

function strider_x1__seal:CalcStatus(duration, caster, target)
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

function strider_x1__seal:RemoveBonus(string, target)
	local stringFormat = string.format("%s_modifier_stack", string)
	local mod = target:FindAllModifiersByName(stringFormat)
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self then modifier:Destroy() end
	end
end

function strider_x1__seal:OnSpellStart()
    local caster = self:GetCaster()
end

function strider_x1__seal:OnUpgrade()
    self:SetHidden(false)
end