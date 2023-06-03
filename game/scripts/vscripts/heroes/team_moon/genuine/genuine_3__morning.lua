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

    if self:GetSpecialValueFor("special_ms_night") == 1
    and (GameRules:IsDaytime() == false or GameRules:IsTemporaryNight()) then
      self:AddNightSpeed()
    end
  end

  function genuine_3__morning:OnUpgrade()
    if self:GetSpecialValueFor("special_ms_night") == 1
    and (GameRules:IsDaytime() == false or GameRules:IsTemporaryNight()) then
      self:AddNightSpeed()
    end
  end

  function genuine_3__morning:GetIntrinsicModifierName()
    return "genuine_3_modifier_passive"
  end

  function genuine_3__morning:GetAOERadius()
    return self:GetSpecialValueFor("special_strike_radius")
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

  function genuine_3__morning:AddNightSpeed()
    local caster = self:GetCaster()
    RemoveAllModifiersByNameAndAbility(caster, "_modifier_movespeed_buff", self)
    AddModifier(caster, caster, self, "_modifier_movespeed_buff", {percent = self:GetSpecialValueFor("ms")}, false)
  end

  function genuine_3__morning:StartStarfalls(enemies)
    local caster = self:GetCaster()
    local starfall_count = self:GetSpecialValueFor("special_starfall_count")

    Timers:CreateTimer(0.1, function()
      for _,enemy in pairs(enemies) do
        if starfall_count <= 0 then break end
        if caster:CanEntityBeSeenByMyTeam(enemy) then
          CreateStarfall(enemy, self)
          starfall_count = starfall_count - 1
        end
      end
    end)
  end

-- EFFECTS