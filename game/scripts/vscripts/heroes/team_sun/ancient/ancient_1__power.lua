ancient_1__power = class({})
LinkLuaModifier("ancient_1_modifier_passive", "heroes/team_sun/ancient/ancient_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_bat_increased", "modifiers/_modifier_bat_increased", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_crit_damage", "modifiers/_modifier_crit_damage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function ancient_1__power:GetIntrinsicModifierName()
    return "ancient_1_modifier_passive"
  end

-- SPELL START

-- EFFECTS