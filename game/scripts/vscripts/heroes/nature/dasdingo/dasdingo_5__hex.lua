dasdingo_5__hex = class({})
LinkLuaModifier("_modifier_hex", "_modifiers/_modifier_hex", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "_modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function dasdingo_5__hex:CastFilterResultTarget(hTarget)
    local caster = self:GetCaster()

    if hTarget:GetTeamNumber() == caster:GetTeamNumber() then
      if caster == hTarget then return UF_SUCCESS end
    end

    local result = UnitFilter(
      hTarget, DOTA_UNIT_TARGET_TEAM_ENEMY,
      self:GetAbilityTargetType(),
      self:GetAbilityTargetFlags(),
      caster:GetTeamNumber()
    )
    
    return result
  end

-- SPELL START

  function dasdingo_5__hex:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local speed = self:GetSpecialValueFor("ms_ally")
    local duration = self:GetSpecialValueFor("duration")

    if target:GetTeamNumber() ~= caster:GetTeamNumber() then
      if target:TriggerSpellAbsorb(self) then return end
      speed = self:GetSpecialValueFor("ms_enemy")
    else
      AddModifier(target, self, "_modifier_movespeed_buff", {duration = duration, percent = 9999}, true)
    end

    AddModifier(target, self, "_modifier_hex", {duration = duration, speed = speed}, true)

    -- ApplyDamage({
    --   attacker = caster, victim = target, ability = self,
    --   damage = self:GetSpecialValueFor("damage"),
    --   damage_type = self:GetAbilityDamageType()
    -- })
  end

-- EFFECTS