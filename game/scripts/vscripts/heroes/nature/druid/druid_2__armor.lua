druid_2__armor = class({})
LinkLuaModifier("druid_2_modifier_passive", "heroes/nature/druid/druid_2_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_2_modifier_armor", "heroes/nature/druid/druid_2_modifier_armor", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function druid_2__armor:GetAOERadius()
    return self:GetSpecialValueFor("special_radius")
  end

  function druid_2__armor:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    ChangeActivity(caster, "suffer")
    return true
  end

  function druid_2__armor:OnAbilityPhaseInterrupted()
    local caster = self:GetCaster()
    ChangeActivity(caster, "")
  end

  function druid_2__armor:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local allies = {[0] = target}

    ChangeActivity(caster, "")

    if self:GetAOERadius() > 0 then
      allies = FindUnitsInRadius(
        caster:GetTeamNumber(), target:GetOrigin(), nil, self:GetAOERadius(),
        self:GetAbilityTargetTeam(), self:GetAbilityTargetType(),
        self:GetAbilityTargetFlags(), 0, false
      )
    end

    for _,ally in pairs(allies) do
      AddModifier(ally, self, "druid_2_modifier_armor", {
        duration = self:GetSpecialValueFor("duration")
      }, true)
    end

    if IsServer() then
      caster:EmitSound("Hero_Treant.LivingArmor.Cast")
      target:EmitSound("Hero_Treant.LivingArmor.Target")
    end
  end

  function druid_2__armor:GetCastAnimation()
    if IsMetamorphosis("druid_4__form", self:GetCaster()) == 1 then return ACT_DOTA_OVERRIDE_ABILITY_2 end
    return ACT_DOTA_CAST_ABILITY_4
  end

  function druid_2__armor:GetBehavior()
    if self:GetAOERadius() > 0 then return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_AOE end
    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
  end

-- EFFECTS