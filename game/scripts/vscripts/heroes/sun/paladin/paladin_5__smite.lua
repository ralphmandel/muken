paladin_5__smite = class({})
LinkLuaModifier("paladin_5_modifier_passive", "heroes/sun/paladin/paladin_5_modifier_passive", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function paladin_5__smite:GetIntrinsicModifierName()
    return "paladin_5_modifier_passive"
  end

-- SPELL START

-- EFFECTS