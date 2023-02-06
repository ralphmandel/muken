bocuse_2__flambee = class({})
LinkLuaModifier("bocuse_2_modifier_flambee", "heroes/bocuse/bocuse_2_modifier_flambee", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

    function bocuse_2__flambee:OnSpellStart()
        local caster = self:GetCaster()
    end

-- EFFECTS