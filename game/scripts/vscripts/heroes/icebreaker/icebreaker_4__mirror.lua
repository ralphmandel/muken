icebreaker_4__mirror = class({})
LinkLuaModifier("icebreaker_4_modifier_passive", "heroes/icebreaker/icebreaker_4_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_phase", "modifiers/_modifier_phase", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible", "modifiers/_modifier_invisible", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible_cosmetics", "modifiers/_modifier_invisible_cosmetics", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

function icebreaker_4__mirror:GetIntrinsicModifierName()
    return "icebreaker_4_modifier_passive"
end

-- EFFECTS