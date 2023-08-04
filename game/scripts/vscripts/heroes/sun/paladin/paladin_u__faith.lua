paladin_u__faith = class({})
LinkLuaModifier("paladin_u_modifier_passive", "heroes/sun/paladin/paladin_u_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("paladin_u_modifier_aura_effect", "heroes/sun/paladin/paladin_u_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function paladin_u__faith:GetIntrinsicModifierName()
    return "paladin_u_modifier_passive"
  end

-- SPELL START

-- EFFECTS