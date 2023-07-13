fleaman_5__steal = class({})
LinkLuaModifier("fleaman_5_modifier_passive", "heroes/death/fleaman/fleaman_5_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("fleaman_5_modifier_steal", "heroes/death/fleaman/fleaman_5_modifier_steal", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function fleaman_5__steal:GetIntrinsicModifierName()
    return "fleaman_5_modifier_passive"
  end

-- SPELL START

-- EFFECTS