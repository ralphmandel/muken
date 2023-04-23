bald_4__clean = class({})
LinkLuaModifier("bald_4_modifier_passive", "heroes/team_sun/bald/bald_4_modifier_passive", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function bald_4__clean:GetIntrinsicModifierName()
    return "bald_4_modifier_passive"
  end

-- EFFECTS