flea_u__weakness = class({})
LinkLuaModifier("flea_u_modifier_passive", "heroes/team_death/flea/flea_u_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_u_modifier_weakness", "heroes/team_death/flea/flea_u_modifier_weakness", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

    function flea_u__weakness:GetIntrinsicModifierName()
        return "flea_u_modifier_passive"
    end

    function flea_u__weakness:OnHeroDiedNearby(unit, attacker, keys)
        local caster = self:GetCaster()
        if unit:GetTeamNumber() == caster:GetTeamNumber() then return end

        local weakness = unit:FindModifierByNameAndCaster("flea_u_modifier_weakness", caster)
        if weakness == nil then return end

        local special_respawn_mult = self:GetSpecialValueFor("special_respawn_mult")
        unit:SetTimeUntilRespawn(unit:GetRespawnTime() + (weakness:GetStackCount() * special_respawn_mult))
    end

-- EFFECTS
