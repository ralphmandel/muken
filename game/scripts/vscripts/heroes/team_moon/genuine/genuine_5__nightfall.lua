genuine_5__nightfall = class({})
LinkLuaModifier("genuine_5_modifier_passive", "heroes/team_moon/genuine/genuine_5_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_5_modifier_barrier", "heroes/team_moon/genuine/genuine_5_modifier_barrier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible", "_modifiers/_modifier_invisible", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invisible_cosmetics", "_modifiers/_modifier_invisible_cosmetics", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function genuine_5__nightfall:OnUpgrade()
    if self:GetLevel() == 1 and (GameRules:IsDaytime() == false or GameRules:IsTemporaryNight()) then
      self:ResetBarrier(true)
    end

    if self:GetSpecialValueFor("special_invi") == 1 then
      self:StartCooldown(self:GetEffectiveCooldown(self:GetLevel()))
    end
  end

  function genuine_5__nightfall:GetIntrinsicModifierName()
    return "genuine_5_modifier_passive"
  end

-- SPELL START

  function genuine_5__nightfall:GetMaxBarrier()
    return self:GetCaster():GetMaxMana() * self:GetSpecialValueFor("max_barrier") * 0.01
  end

  function genuine_5__nightfall:ResetBarrier(bEnabled)
    local caster = self:GetCaster()
    caster:RemoveModifierByName("genuine_5_modifier_barrier")

    if bEnabled then
      AddModifier(caster, caster, self, "genuine_5_modifier_barrier", {}, false)
    end
  end

-- EFFECTS