icebreaker_2__wave = class({})
LinkLuaModifier("icebreaker__modifier_hypo", "heroes/team_moon/icebreaker/icebreaker__modifier_hypo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo_status_efx", "heroes/team_moon/icebreaker/icebreaker__modifier_hypo_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo_dps", "heroes/team_moon/icebreaker/icebreaker__modifier_hypo_dps", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen", "heroes/team_moon/icebreaker/icebreaker__modifier_frozen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen_status_efx", "heroes/team_moon/icebreaker/icebreaker__modifier_frozen_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_instant", "heroes/team_moon/icebreaker/icebreaker__modifier_instant", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_instant_status_efx", "heroes/team_moon/icebreaker/icebreaker__modifier_instant_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_illusion", "heroes/team_moon/icebreaker/icebreaker__modifier_illusion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_2_modifier_refresh", "heroes/team_moon/icebreaker/icebreaker_2_modifier_refresh", LUA_MODIFIER_MOTION_NONE)

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

    caster:AddNewModifier(caster, self, "icebreaker_2_modifier_refresh", {})

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
    local silence_duration = self:GetSpecialValueFor("special_silence_duration")
    local damage_percent = self:GetSpecialValueFor("special_damage_percent")
    local knockback_distance = CalcStatus(self:GetSpecialValueFor("special_knockback_distance"), caster, target)
    local knockback_duration = CalcStatus(self:GetSpecialValueFor("special_knockback_duration"), caster, target)

    if silence_duration > 0 then
      target:AddNewModifier(caster, self, "_modifier_silence", {
        duration = CalcStatus(silence_duration, caster, target)
      })
    end

    if knockback_distance > 0 then
      self.knockbackProperties.duration = knockback_duration
      self.knockbackProperties.knockback_duration = knockback_duration
      self.knockbackProperties.knockback_distance = knockback_distance
      target:AddNewModifier(caster, nil, "modifier_knockback", self.knockbackProperties)
    end

    if self.first_hit == false then
      caster:MoveToTargetToAttack(target)
      self.first_hit = true
    end

    if damage_percent > 0 then
      ApplyDamage({
        attacker = caster, victim = target,
        damage = target:GetMaxHealth() * damage_percent * 0.01,
        damage_type = DAMAGE_TYPE_MAGICAL, ability = self
      })
    end

    if target then
      if IsValidEntity(target) then
        if target:IsAlive() then
          target:AddNewModifier(caster, self, "icebreaker__modifier_hypo", {
            stack = RandomInt(self:GetSpecialValueFor("hypo_stack_min"), self:GetSpecialValueFor("hypo_stack_max"))
          })
        end
      end
    end
  end

-- EFFECTS