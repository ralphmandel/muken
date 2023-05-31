genuine_5__nightfall = class({})
LinkLuaModifier("genuine_5_modifier_passive", "heroes/team_moon/genuine/genuine_5_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_5_modifier_barrier", "heroes/team_moon/genuine/genuine_5_modifier_barrier", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function genuine_5__nightfall:OnUpgrade()
    self.barrier = self:GetMaxBarrier()
  end

  function genuine_5__nightfall:OnOwnerSpawned()
    self.barrier = self:GetMaxBarrier()
    self:ResetBarrier()
  end

  function genuine_5__nightfall:GetIntrinsicModifierName()
    return "genuine_5_modifier_passive"
  end

-- SPELL START

  function genuine_5__nightfall:GetMaxBarrier()
    return self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("barrier_percent") * 0.01
  end

  function genuine_5__nightfall:ResetBarrier()
    local caster = self:GetCaster()
    caster:RemoveModifierByName("genuine_5_modifier_barrier")

    Timers:CreateTimer(FrameTime(), function()
      AddModifier(caster, caster, self, "genuine_5_modifier_barrier", {}, false)
    end)
  end

-- EFFECTS