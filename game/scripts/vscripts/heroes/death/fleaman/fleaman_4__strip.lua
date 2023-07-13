fleaman_4__strip = class({})
LinkLuaModifier("fleaman_4_modifier_passive", "heroes/death/fleaman/fleaman_4_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("fleaman_4_modifier_strip", "heroes/death/fleaman/fleaman_4_modifier_strip", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function fleaman_4__strip:GetIntrinsicModifierName()
    return "fleaman_4_modifier_passive"
  end

-- SPELL START

-- EFFECTS