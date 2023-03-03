druid_1__root = class({})
LinkLuaModifier("druid_1_modifier_root", "heroes/druid/druid_1_modifier_root", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

    function druid_1__root:OnSpellStart()
        local caster = self:GetCaster()
    end

-- EFFECTS