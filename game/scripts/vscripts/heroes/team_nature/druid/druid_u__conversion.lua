druid_u__conversion = class({})
LinkLuaModifier("druid_u_modifier_conversion", "heroes/team_nature/druid/druid_u_modifier_conversion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_u_modifier_passive", "heroes/team_nature/druid/druid_u_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_u_modifier_channel", "heroes/team_nature/druid/druid_u_modifier_channel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_u_modifier_aura", "heroes/team_nature/druid/druid_u_modifier_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_u_modifier_aura_effect", "heroes/team_nature/druid/druid_u_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_u_modifier_reborn", "heroes/team_nature/druid/druid_u_modifier_reborn", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_phase", "modifiers/_modifier_phase", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_manaloss", "modifiers/_modifier_manaloss", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_hex", "modifiers/_modifier_hex", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function druid_u__conversion:Spawn()
    self:SetCurrentAbilityCharges(0)
    self.DominateTable = {}
  end

  function druid_u__conversion:GetIntrinsicModifierName()
    return "druid_u_modifier_passive"
  end

  function druid_u__conversion:GetAOERadius()
    return self:GetSpecialValueFor("radius")
  end

  function druid_u__conversion:GetChannelAnimation()
    return ACT_DOTA_VICTORY
  end

  function druid_u__conversion:GetBehavior()
    if self:GetCaster():FindAbilityByName("druid_4__form"):GetCurrentAbilityCharges() == 1 then
      return DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE + DOTA_ABILITY_BEHAVIOR_PASSIVE
    end

    return DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE + DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_CHANNELLED
  end

-- SPELL START

  function druid_u__conversion:OnSpellStart()
    local caster = self:GetCaster()
    self.point = self:GetCursorPosition()

    caster:RemoveModifierByNameAndCaster("druid_u_modifier_channel", caster)
    caster:AddNewModifier(caster, self, "druid_u_modifier_channel", {})
  end

  function druid_u__conversion:OnChannelFinish(bInterrupted)
    local caster = self:GetCaster()
    caster:RemoveModifierByNameAndCaster("druid_u_modifier_channel", caster)
  end

  function druid_u__conversion:AddUnit(unit)
    local caster = self:GetCaster()
    local max_dominate = self:GetSpecialValueFor("max_dominate")
    local unit_lvl = unit:GetLevel()

    if self:GetCurrentTableLvl() + unit_lvl > max_dominate then
      self:GetWeakerUnit():Kill(nil, nil)
      self:AddUnit(unit)
      return
    end

    table.insert(self.DominateTable, unit)
    self:UpdateUnitCount()
  end

  function druid_u__conversion:RemoveUnit(unit)
    for i = #self.DominateTable, 1, -1 do
      if self.DominateTable[i] == unit then
        table.remove(self.DominateTable, i)
        break
      end
    end

    self:UpdateUnitCount()
  end

  function druid_u__conversion:GetWeakerUnit()
    local unit = nil
    local min_lvl = 100

    for _,unit_table in pairs(self.DominateTable) do
      if unit_table:GetLevel() < min_lvl then
        min_lvl = unit_table:GetLevel()
        unit = unit_table
      end
    end

    return unit
  end

  function druid_u__conversion:GetCurrentTableLvl()
    local lvl = 0

    for _,unit_table in pairs(self.DominateTable) do
      lvl = lvl + unit_table:GetLevel()
    end

    return lvl
  end

  function druid_u__conversion:UpdateUnitCount()
    local caster = self:GetCaster()
    caster:FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), caster):SetStackCount(self:GetCurrentTableLvl())
  end

-- EFFECTS