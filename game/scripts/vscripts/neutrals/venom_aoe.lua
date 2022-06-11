venom_aoe = class({})
LinkLuaModifier( "venom_aoe_modifier", "neutrals/venom_aoe_modifier", LUA_MODIFIER_MOTION_NONE )

function venom_aoe:CalcStatus(duration, caster, target)
    local time = duration
	local base_stats_caster = nil
	local base_stats_target = nil

    if caster ~= nil then
		base_stats_caster = caster:FindAbilityByName("base_stats")
	end

	if target ~= nil then
		base_stats_target = target:FindAbilityByName("base_stats")
	end

	if caster == nil then
		if target ~= nil then
			if base_stats_target then
				local value = base_stats_target.res_total * 0.01
				local calc = (value * 6) / (1 +  (value * 0.06))
				time = time * (1 - calc)
			end
		end
	else
		if target == nil then
			if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
		else
			if caster:GetTeamNumber() == target:GetTeamNumber() then
				if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
			else
				if base_stats_caster and base_stats_target then
					local value = (base_stats_caster.int_total - base_stats_target.res_total) * 0.01
					if value > 0 then
						local calc = (value * 6) / (1 +  (value * 0.06))
						time = time * (1 + calc)
					else
						value = -1 * value
						local calc = (value * 6) / (1 +  (value * 0.06))
						time = time * (1 - calc)
					end
				end
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