immunity = class({})
LinkLuaModifier("_modifier_immunity", "modifiers/_modifier_immunity", LUA_MODIFIER_MOTION_NONE)

function immunity:CalcStatus(duration, caster, target)
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

function immunity:AddBonus(string, target, const, percent, time)
	local base_stats = target:FindAbilityByName("base_stats")
	if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
end

function immunity:RemoveBonus(string, target)
	local stringFormat = string.format("%s_modifier_stack", string)
	local mod = target:FindAllModifiersByName(stringFormat)
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self then modifier:Destroy() end
	end
end

function immunity:OnSpellStart()
    local caster = self:GetCaster()
    local radius = self:GetSpecialValueFor("radius")
    local duration = self:GetSpecialValueFor("duration")

    local allies = FindUnitsInRadius(
		caster:GetTeamNumber(),	-- int, your team number
		caster:GetOrigin(),	-- point, center point
		nil,	-- handle, cacheUnit. (not known)
		radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
		DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- int, team filter
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
		0,	-- int, flag filter
		0,	-- int, order filter
		false	-- bool, can grow cache
	)

	for _,ally in pairs(allies) do
		ally:AddNewModifier(caster, self, "_modifier_immunity", {
            duration = self:CalcStatus(duration, caster, ally)
        })
	end

    if IsServer() then caster:EmitSound("Hero_Omniknight.GuardianAngel.Cast") end
end