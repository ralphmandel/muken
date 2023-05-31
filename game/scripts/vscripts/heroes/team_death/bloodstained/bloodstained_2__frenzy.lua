bloodstained_2__frenzy = class({})
LinkLuaModifier("bloodstained_2_modifier_passive", "heroes/team_death/bloodstained/bloodstained_2_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_2_modifier_frenzy", "heroes/team_death/bloodstained/bloodstained_2_modifier_frenzy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "_modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function bloodstained_2__frenzy:GetIntrinsicModifierName()
    return "bloodstained_2_modifier_passive"
  end

-- EFFECTS