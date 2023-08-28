ancient_5__flesh = class({})
LinkLuaModifier("ancient_5_modifier_passive", "heroes/sun/ancient/ancient_5_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function ancient_5__flesh:GetIntrinsicModifierName()
    return "ancient_5_modifier_passive"
  end

-- SPELL START

-- EFFECTS