fountain = class({})
LinkLuaModifier( "fountain_modifier", "neutrals/fountain_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("_modifier_truesight", "modifiers/_modifier_truesight", LUA_MODIFIER_MOTION_NONE)

function fountain:CalcStatus(duration, caster, target)
    local time = duration
	local caster_int = nil
    local caster_mnd = nil
	local target_res = nil

    if caster ~= nil then
		caster_int = caster:FindModifierByName("_1_INT_modifier")
		caster_mnd = caster:FindModifierByName("_2_MND_modifier")
	end

	if target ~= nil then
		target_res = target:FindModifierByName("_2_RES_modifier")
	end

	if caster == nil then
		if target ~= nil then
			if target_res then time = time * (1 - target_res:GetStatus()) end
		end
	else
		if target == nil then
			if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
		else
			if caster:GetTeamNumber() == target:GetTeamNumber() then
				if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
			else
				if caster_int then time = duration * (1 + caster_int:GetDebuffTime()) end
				if target_res then time = time * (1 - target_res:GetStatus()) end
			end
		end
	end

    if time < 0 then time = 0 end
    return time
end

function fountain:GetIntrinsicModifierName()
	return "fountain_modifier"
end

-- function fountain:Spawn()
--     local caster = self:GetCaster()
--     CreateModifierThinker(caster, self, "fountain_modifier", {}, caster:GetOrigin(), caster:GetTeamNumber(), false)
-- end