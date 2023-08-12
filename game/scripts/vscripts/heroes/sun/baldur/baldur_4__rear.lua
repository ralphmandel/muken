baldur_4__rear = class({})
LinkLuaModifier("baldur_4_modifier_passive", "heroes/sun/baldur/baldur_4_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function baldur_4__rear:GetIntrinsicModifierName()
    return "baldur_4_modifier_passive"
  end

-- SPELL START

-- EFFECTS