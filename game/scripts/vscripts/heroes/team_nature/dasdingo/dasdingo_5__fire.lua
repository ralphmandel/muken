dasdingo_5__fire = class({})
LinkLuaModifier("dasdingo_5_modifier_passive", "heroes/team_nature/dasdingo/dasdingo_5_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_5_modifier_fire", "heroes/team_nature/dasdingo/dasdingo_5_modifier_fire", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_5_modifier_ignition", "heroes/team_nature/dasdingo/dasdingo_5_modifier_ignition", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function dasdingo_5__fire:GetIntrinsicModifierName()
    return "dasdingo_5_modifier_passive"
  end

-- SPELL START

-- EFFECTS