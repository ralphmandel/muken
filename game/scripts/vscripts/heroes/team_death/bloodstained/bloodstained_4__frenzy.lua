bloodstained_4__frenzy = class({})
LinkLuaModifier("bloodstained_4_modifier_passive", "heroes/team_death/bloodstained/bloodstained_4_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_4_modifier_frenzy", "heroes/team_death/bloodstained/bloodstained_4_modifier_frenzy", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function bloodstained_4__frenzy:GetIntrinsicModifierName()
    return "bloodstained_4_modifier_passive"
  end

-- EFFECTS