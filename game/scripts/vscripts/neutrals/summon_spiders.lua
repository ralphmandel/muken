summon_spiders = class({})
LinkLuaModifier( "summon_spiders_modifier", "neutrals/summon_spiders_modifier", LUA_MODIFIER_MOTION_NONE )

function summon_spiders:CalcStatus(duration, caster, target)
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

function summon_spiders:OnSpellStart()
    local caster = self:GetCaster()
    local point = caster:GetCursorPosition()

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
        local spider = CreateUnitByName("summoner_spider", point, true, nil, nil, DOTA_TEAM_NEUTRALS)
        spider:AddNewModifier(caster, self, "summon_spiders_modifier", {duration = 20})
    end
end