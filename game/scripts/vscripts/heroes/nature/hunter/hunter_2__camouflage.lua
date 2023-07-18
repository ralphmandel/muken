hunter_2__camouflage = class({})
LinkLuaModifier("hunter_2_modifier_passive", "heroes/nature/hunter/hunter_2_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("hunter_2_modifier_delay_end", "heroes/nature/hunter/hunter_2_modifier_delay_end", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible", "_modifiers/_modifier_invisible", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible_cosmetics", "_modifiers/_modifier_invisible_cosmetics", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function hunter_2__camouflage:GetIntrinsicModifierName()
    return "hunter_2_modifier_passive"
  end

-- SPELL START

-- EFFECTS