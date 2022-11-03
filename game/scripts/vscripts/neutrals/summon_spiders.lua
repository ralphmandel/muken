summon_spiders = class({})
LinkLuaModifier( "summon_spiders_modifier", "neutrals/summon_spiders_modifier", LUA_MODIFIER_MOTION_NONE )

function summon_spiders:CalcStatus(duration, caster, target)
    if caster == nil or target == nil then return duration end
    if IsValidEntity(caster) == false or IsValidEntity(target) == false then return duration end
    local base_stats = caster:FindAbilityByName("base_stats")

    if caster:GetTeamNumber() == target:GetTeamNumber() then
        if base_stats then duration = duration * (1 + base_stats:GetBuffAmp()) end
    else
        if base_stats then duration = duration * (1 + base_stats:GetDebuffAmp()) end
        duration = duration * (1 - target:GetStatusResistance())
    end
    
    return duration
end

function summon_spiders:AddBonus(string, target, const, percent, time)
	local base_stats = target:FindAbilityByName("base_stats")
	if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
end

function summon_spiders:RemoveBonus(string, target)
	local stringFormat = string.format("%s_modifier_stack", string)
	local mod = target:FindAllModifiersByName(stringFormat)
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self then modifier:Destroy() end
	end
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