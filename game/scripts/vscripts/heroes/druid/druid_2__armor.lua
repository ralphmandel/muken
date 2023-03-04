druid_2__armor = class({})
LinkLuaModifier("druid_2_modifier_passive", "heroes/druid/druid_2_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_2_modifier_armor", "heroes/druid/druid_2_modifier_armor", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function druid_2__armor:GetIntrinsicModifierName()
    return "druid_2_modifier_passive"
  end

  function druid_2__armor:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    caster:FindModifierByName("base_hero_mod"):ChangeActivity("suffer")
    return true
  end

  function druid_2__armor:OnAbilityPhaseInterrupted()
    local caster = self:GetCaster()
    caster:FindModifierByName("base_hero_mod"):ChangeActivity("")
  end

  function druid_2__armor:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

		caster:FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), caster):DecrementStackCount()

    caster:FindModifierByName("base_hero_mod"):ChangeActivity("")
    target:AddNewModifier(caster, self, "druid_2_modifier_armor", {
      duration = CalcStatus(self:GetSpecialValueFor("duration"), caster, target)
    })
  end

  function druid_2__armor:GetCastAnimation()
    if IsMetamorphosis("druid_4__form", self:GetCaster()) then return ACT_DOTA_OVERRIDE_ABILITY_2 end
    return ACT_DOTA_CAST_ABILITY_4
  end


-- EFFECTS