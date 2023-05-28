bald_1__power = class({})
LinkLuaModifier("bald_1_modifier_passive", "heroes/team_sun/bald/bald_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bald_1_modifier_passive_stack", "heroes/team_sun/bald/bald_1_modifier_passive_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_break", "_modifiers/_modifier_break", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function bald_1__power:GetIntrinsicModifierName()
    return "bald_1_modifier_passive"
  end

-- EFFECTS