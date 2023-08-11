baldur_1__power = class({})
LinkLuaModifier("baldur_1_modifier_passive", "heroes/sun/baldur/baldur_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function baldur_1__power:Spawn()
    Timers:CreateTimer(0.2, function()
      if self:IsTrained() == false then
        self:UpgradeAbility(true)
        BaseStats(self:GetCaster()):AddManaExtra(self)
      end
    end)
  end

  function baldur_1__power:GetIntrinsicModifierName()
		return "baldur_1_modifier_passive"
	end

-- SPELL START

-- EFFECTS