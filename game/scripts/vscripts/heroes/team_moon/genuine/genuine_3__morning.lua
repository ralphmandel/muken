genuine_3__morning = class({})
LinkLuaModifier("genuine_3_modifier_passive", "heroes/team_moon/genuine/genuine_3_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_3_modifier_morning", "heroes/team_moon/genuine/genuine_3_modifier_morning", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "_modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function genuine_3__morning:Spawn()
    self.kills = 0

    Timers:CreateTimer(0.2, function()
      if self:IsTrained() == false then
        self:UpgradeAbility(true)
      end
    end)
  end

  function genuine_3__morning:OnOwnerSpawned()
    self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName()):StopEfxBuff()
    self:SetActivated(true)
  end

  function genuine_3__morning:GetIntrinsicModifierName()
    return "genuine_3_modifier_passive"
  end

-- SPELL START

  function genuine_3__morning:OnAbilityPhaseStart()
    self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName()):PlayEfxBuff()
    return true
  end

  function genuine_3__morning:OnAbilityPhaseInterrupted()
    self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName()):StopEfxBuff()
  end

  function genuine_3__morning:OnSpellStart()
    local caster = self:GetCaster()
    AddModifier(caster, caster, self, "genuine_3_modifier_morning", {duration = self:GetSpecialValueFor("duration")}, true)
  end

-- EFFECTS