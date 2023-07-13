bloodstained_5__lifesteal = class({})
LinkLuaModifier("bloodstained_5_modifier_passive", "heroes/death/bloodstained/bloodstained_5_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_5_modifier_passive_status_efx", "heroes/death/bloodstained/bloodstained_5_modifier_passive_status_efx", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function bloodstained_5__lifesteal:Spawn()
    Timers:CreateTimer(0.2, function()
      if self:IsTrained() == false then
        self:UpgradeAbility(true)
        BaseStats(self:GetCaster()):AddManaExtra(self)
      end
    end)
  end

  function bloodstained_5__lifesteal:GetIntrinsicModifierName()
    return "bloodstained_5_modifier_passive"
  end

-- SPELL START

-- EFFECTS