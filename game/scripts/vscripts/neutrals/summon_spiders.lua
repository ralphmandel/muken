summon_spiders = class({})
LinkLuaModifier( "summon_spiders_modifier", "neutrals/summon_spiders_modifier", LUA_MODIFIER_MOTION_NONE )

function summon_spiders:CalcStatus(duration, caster, target)
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

function summon_spiders:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local point = target:GetOrigin()

	local units = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		FIND_UNITS_EVERYWHERE,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

    for _,unit in pairs(units) do
        unit:RemoveModifierByName("summon_spiders_modifier")
    end

    local spiders_number = self:GetSpecialValueFor("spiders_number")
    for i = 1, spiders_number, 1 do
        local spider = CreateUnitByName("summoner_spider", point, true, nil, nil, caster:GetTeamNumber())
        spider:AddNewModifier(caster, self, "summon_spiders_modifier", {duration = 20})
        spider:SetForceAttackTarget(target)
    end
end