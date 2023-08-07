icebreaker_2__wave = class({})
LinkLuaModifier("icebreaker_2_modifier_refresh", "heroes/moon/icebreaker/icebreaker_2_modifier_refresh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_silence", "_modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_slow", "heroes/moon/icebreaker/icebreaker__modifier_slow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo", "heroes/moon/icebreaker/icebreaker__modifier_hypo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo_status_efx", "heroes/moon/icebreaker/icebreaker__modifier_hypo_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen", "heroes/moon/icebreaker/icebreaker__modifier_frozen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen_status_efx", "heroes/moon/icebreaker/icebreaker__modifier_frozen_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_bat_increased", "_modifiers/_modifier_bat_increased", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function icebreaker_2__wave:OnOwnerSpawned()
    self:SetActivated(true)
  end

-- SPELL START

  function icebreaker_2__wave:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local direction = (point - caster:GetAbsOrigin()):Normalized()
    self.first_hit = false

    AddModifier(caster, self, "icebreaker_2_modifier_refresh", {}, false)

    if IsServer() then caster:EmitSound("Hero_Ancient_Apparition.IceBlast.Target") end
    
    ProjectileManager:CreateLinearProjectile({
      Ability = self,
      EffectName = "particles/econ/items/drow/drow_arcana/drow_arcana_silence_wave.vpcf",
      vSpawnOrigin = caster:GetAbsOrigin(),
      Source = caster,
      bHasFrontalCone = true,
      bReplaceExisting = false,
      fStartRadius = self:GetSpecialValueFor("radius"),
      fEndRadius = self:GetSpecialValueFor("radius"),
      fDistance = self:GetSpecialValueFor("distance"),
      iUnitTargetTeam = self:GetAbilityTargetTeam(),
      iUnitTargetFlags = self:GetAbilityTargetFlags(),
      iUnitTargetType = self:GetAbilityTargetType(),
      fExpireTime = GameRules:GetGameTime() + 10.0,
      bDeleteOnHit = false,
      vVelocity = direction * self:GetSpecialValueFor("speed"),
      bProvidesVision = true,
      iVisionRadius = self:GetSpecialValueFor("radius"),
      iVisionTeamNumber = caster:GetTeamNumber()
    })

    self.knockbackProperties = {
      center_x = caster:GetAbsOrigin().x + 1,
      center_y = caster:GetAbsOrigin().y + 1,
      center_z = caster:GetAbsOrigin().z,
      knockback_height = 0
    }
  end

  function icebreaker_2__wave:OnProjectileHit(target, vLocation)
    if target == nil then return end
    if IsServer() then target:EmitSound("Hero_Lich.preAttack") end

    local caster = self:GetCaster()
    local stack = RandomInt(self:GetSpecialValueFor("stack_min"), self:GetSpecialValueFor("stack_max"))
    local knockback_distance = self:GetSpecialValueFor("knockback_distance")
    local knockback_duration = self:GetSpecialValueFor("knockback_duration")

    if self.first_hit == false then
      if caster:IsCommandRestricted() == false then
        caster:MoveToTargetToAttack(target)
      end
      self.first_hit = true
    end

    self.knockbackProperties.duration = knockback_duration * stack
    self.knockbackProperties.knockback_duration = CalcStatus(knockback_duration, caster, target) * stack
    self.knockbackProperties.knockback_distance = CalcStatus(knockback_distance, caster, target) * stack

    AddModifier(target, self, "modifier_knockback", self.knockbackProperties, true)
    AddModifier(target, self, "icebreaker__modifier_hypo", {stack = stack}, false)
  end

-- EFFECTS