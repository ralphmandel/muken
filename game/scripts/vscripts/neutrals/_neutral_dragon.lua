_neutral_dragon = class({})
LinkLuaModifier( "_modifier_neutral_dragon", "neutrals/_modifier_neutral_dragon", LUA_MODIFIER_MOTION_NONE )

function _neutral_dragon:CalcStatus(duration, caster, target)
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
				local value = base_stats_target.stat_total["RES"] * 0.4
				local calc = (value * 6) / (1 +  (value * 0.06))
				time = time * (1 - (calc * 0.01))
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
					local value = (base_stats_caster.stat_total["INT"] - base_stats_target.stat_total["RES"]) * 0.7
					if value > 0 then
						local calc = (value * 6) / (1 +  (value * 0.06))
						time = time * (1 + (calc * 0.01))
					else
						value = -1 * value
						local calc = (value * 6) / (1 +  (value * 0.06))
						time = time * (1 - (calc * 0.01))
					end
				end
			end
		end
	end

    if time < 0 then time = 0 end
    return time
end

function _neutral_dragon:GetIntrinsicModifierName()
	return "_modifier_neutral_dragon"
end