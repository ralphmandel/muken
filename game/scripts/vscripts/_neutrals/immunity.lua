immunity = class({})
LinkLuaModifier("_modifier_immunity", "_modifiers/_modifier_immunity", LUA_MODIFIER_MOTION_NONE)

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
            duration = CalcStatus(duration, caster, ally)
        })
	end

    if IsServer() then caster:EmitSound("Hero_Omniknight.GuardianAngel.Cast") end
end