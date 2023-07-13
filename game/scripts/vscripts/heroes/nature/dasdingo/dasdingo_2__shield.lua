dasdingo_2__shield = class({})
LinkLuaModifier("dasdingo_2_modifier_aura", "heroes/nature/dasdingo/dasdingo_2_modifier_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_2_modifier_aura_effect", "heroes/nature/dasdingo/dasdingo_2_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function dasdingo_2__shield:GetAOERadius()
    return self:GetSpecialValueFor("radius")
  end

  function dasdingo_2__shield:GetIntrinsicModifierName()
    return "dasdingo_2_modifier_aura"
  end

-- SPELL START

-- EFFECTS