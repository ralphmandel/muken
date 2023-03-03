druid_2__armor = class({})
LinkLuaModifier("druid_2_modifier_armor", "heroes/druid/druid_2_modifier_armor", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

    function druid_2__armor:OnSpellStart()
        local caster = self:GetCaster()
    end

-- EFFECTS