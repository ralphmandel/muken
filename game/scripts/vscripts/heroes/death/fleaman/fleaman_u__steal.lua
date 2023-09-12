fleaman_u__steal = class({})
LinkLuaModifier("fleaman_u_modifier_passive", "heroes/death/fleaman/fleaman_u_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("fleaman_u_modifier_steal", "heroes/death/fleaman/fleaman_u_modifier_steal", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function fleaman_u__steal:GetIntrinsicModifierName()
    return "fleaman_u_modifier_passive"
  end

-- SPELL START

-- EFFECTS