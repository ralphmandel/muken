flea_u__weakness = class({})
LinkLuaModifier("flea_u_modifier_passive", "heroes/flea/flea_u_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_u_modifier_weakness", "heroes/flea/flea_u_modifier_weakness", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_u_modifier_weakness_stack", "heroes/flea/flea_u_modifier_weakness_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

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
