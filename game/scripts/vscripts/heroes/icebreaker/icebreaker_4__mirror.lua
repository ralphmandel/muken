icebreaker_4__mirror = class({})
LinkLuaModifier("icebreaker_4_modifier_passive", "heroes/icebreaker/icebreaker_4_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_4_modifier_invi", "heroes/icebreaker/icebreaker_4_modifier_invi", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo", "heroes/icebreaker/icebreaker__modifier_hypo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen", "heroes/icebreaker/icebreaker__modifier_frozen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_instant", "heroes/icebreaker/icebreaker__modifier_instant", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo_status_efx", "heroes/icebreaker/icebreaker__modifier_hypo_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen_status_efx", "heroes/icebreaker/icebreaker__modifier_frozen_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_instant_status_efx", "heroes/icebreaker/icebreaker__modifier_instant_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible", "modifiers/_modifier_invisible", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible_cosmetics", "modifiers/_modifier_invisible_cosmetics", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

function icebreaker_4__mirror:GetIntrinsicModifierName()
    return "icebreaker_4_modifier_passive"
end

-- EFFECTS