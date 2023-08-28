hunter_u__camouflage = class({})
LinkLuaModifier("hunter_u_modifier_passive", "heroes/nature/hunter/hunter_u_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("hunter_u_modifier_camouflage", "heroes/nature/hunter/hunter_u_modifier_camouflage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invi_level", "_modifiers/_modifier_invi_level", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_no_vision_attacker", "_modifiers/_modifier_no_vision_attacker", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function hunter_u__camouflage:GetIntrinsicModifierName()
    return "hunter_u_modifier_passive"
  end

-- SPELL START

-- EFFECTS