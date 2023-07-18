hunter_u__aim = class({})
LinkLuaModifier("hunter_u_modifier_passive", "heroes/nature/hunter/hunter_u_modifier_passive", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function hunter_u__aim:GetIntrinsicModifierName()
    return "hunter_u_modifier_passive"
  end

-- SPELL START

-- EFFECTS