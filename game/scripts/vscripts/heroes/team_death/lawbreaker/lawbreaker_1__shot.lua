lawbreaker_1__shot = class({})
LinkLuaModifier("lawbreaker_1_modifier_passive", "heroes/team_death/lawbreaker/lawbreaker_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function lawbreaker_1__shot:Spawn()
    Timers:CreateTimer(0.2, function()
      if self:IsTrained() == false then
        self:UpgradeAbility(true)
        BaseStats(self:GetCaster()):AddManaExtra(self)
      end
    end)
  end

-- SPELL START

	function lawbreaker_1__shot:GetIntrinsicModifierName()
		return "lawbreaker_1_modifier_passive"
	end

-- EFFECTS