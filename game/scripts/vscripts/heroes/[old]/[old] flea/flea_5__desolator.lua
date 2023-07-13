flea_5__desolator = class({})
LinkLuaModifier("flea_5_modifier_passive", "heroes/death/flea/flea_5_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("flea_5_modifier_desolator", "heroes/death/flea/flea_5_modifier_desolator", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

    function flea_5__desolator:GetIntrinsicModifierName()
        return "flea_5_modifier_passive"
    end

-- EFFECTS