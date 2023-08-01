shaman_5__fire = class({})
LinkLuaModifier("shaman_5_modifier_passive", "heroes/nature/shaman/shaman_5_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shaman_5_modifier_fire", "heroes/nature/shaman/shaman_5_modifier_fire", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shaman_5_modifier_ignition", "heroes/nature/shaman/shaman_5_modifier_ignition", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function shaman_5__fire:GetIntrinsicModifierName()
    return "shaman_5_modifier_passive"
  end

-- SPELL START

-- EFFECTS