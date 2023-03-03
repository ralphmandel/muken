druid_3__totem = class({})
LinkLuaModifier("druid_3_modifier_totem", "heroes/druid/druid_3_modifier_totem", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

    function druid_3__totem:OnSpellStart()
        local caster = self:GetCaster()
    end

-- EFFECTS