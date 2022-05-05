venom_aoe = class({})
LinkLuaModifier( "venom_aoe_modifier", "neutrals/venom_aoe_modifier", LUA_MODIFIER_MOTION_NONE )

function venom_aoe:CalcStatus(duration, caster, target)
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

function venom_aoe:GetAOERadius()
    return self:GetSpecialValueFor("radius")
end

function venom_aoe:OnSpellStart()
    local caster = self:GetCaster()
    local point = caster:GetCursorPosition()
    local duration = self:GetSpecialValueFor("duration")

    CreateModifierThinker(caster, self, "venom_aoe_modifier", {duration = duration}, point, caster:GetTeamNumber(), false)
end

function venom_aoe:OnOwnerDied()
	local caster = self:GetCaster()

	local thinkers = Entities:FindAllByClassname("npc_dota_thinker")
	for _,thinker in pairs(thinkers) do
		if thinker:GetOwner() == caster and thinker:HasModifier("venom_aoe_modifier") then
			thinker:RemoveModifierByName("venom_aoe_modifier")
			--thinker:Kill(self, nil)
		end
	end
end