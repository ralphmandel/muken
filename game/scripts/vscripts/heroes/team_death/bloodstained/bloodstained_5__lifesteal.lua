bloodstained_5__lifesteal = class({})
LinkLuaModifier("bloodstained_5_modifier_passive", "heroes/team_death/bloodstained/bloodstained_5_modifier_passive", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function bloodstained_5__lifesteal:Spawn()
    if self:IsTrained() == false then self:UpgradeAbility(true) end
  end

  function bloodstained_5__lifesteal:GetIntrinsicModifierName()
    return "bloodstained_5_modifier_passive"
  end

-- SPELL START

-- EFFECTS