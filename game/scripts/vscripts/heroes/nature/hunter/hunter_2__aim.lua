hunter_2__aim = class({})
LinkLuaModifier("hunter_2_modifier_passive", "heroes/nature/hunter/hunter_2_modifier_passive", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function hunter_2__aim:GetIntrinsicModifierName()
    return "hunter_2_modifier_passive"
  end

-- SPELL START

-- EFFECTS