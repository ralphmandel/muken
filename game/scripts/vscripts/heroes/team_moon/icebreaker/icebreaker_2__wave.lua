icebreaker_2__wave = class({})
LinkLuaModifier("icebreaker__modifier_hypo", "heroes/team_moon/icebreaker/icebreaker__modifier_hypo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo_status_efx", "heroes/team_moon/icebreaker/icebreaker__modifier_hypo_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo_dps", "heroes/team_moon/icebreaker/icebreaker__modifier_hypo_dps", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen", "heroes/team_moon/icebreaker/icebreaker__modifier_frozen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen_status_efx", "heroes/team_moon/icebreaker/icebreaker__modifier_frozen_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_instant", "heroes/team_moon/icebreaker/icebreaker__modifier_instant", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_instant_status_efx", "heroes/team_moon/icebreaker/icebreaker__modifier_instant_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_illusion", "heroes/team_moon/icebreaker/icebreaker__modifier_illusion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_bat_increased", "modifiers/_modifier_bat_increased", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_2_modifier_refresh", "heroes/team_moon/icebreaker/icebreaker_2_modifier_refresh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_silence", "modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)

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

    AddModifier(caster, caster, self, "icebreaker_2_modifier_refresh", {}, false)

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
    local stack = RandomInt(self:GetSpecialValueFor("hypo_stack_min"), self:GetSpecialValueFor("hypo_stack_max"))
    local knockback_distance = self:GetSpecialValueFor("special_knockback_distance")
    local knockback_duration = self:GetSpecialValueFor("special_knockback_duration")
    local damage = self:GetSpecialValueFor("special_damage")
    local mana_burn = self:GetSpecialValueFor("special_mana_burn")

    if damage > 0 then
      ApplyDamage({
        victim = target, attacker = caster, ability = self,
        damage =  target:GetBaseMaxHealth() * damage * stack * 0.01,
        damage_type = self:GetAbilityDamageType()
      })
    end

    if target == nil then return end
    if IsValidEntity(target) == false then return end
    if target:IsAlive() == false then return end

    if self.first_hit == false then
      caster:MoveToTargetToAttack(target)
      self.first_hit = true
    end

    if knockback_distance > 0 then
      self.knockbackProperties.duration = knockback_duration * stack
      self.knockbackProperties.knockback_duration = CalcStatus(knockback_duration, caster, target) * stack
      self.knockbackProperties.knockback_distance = CalcStatus(knockback_distance, caster, target) * stack
      AddModifier(target, caster, nil, "modifier_knockback", self.knockbackProperties, true)
    end

    if mana_burn > 0 and target:GetMana() > 0 then
      local init_mana = target:GetMana()
      ReduceMana(target, self, target:GetMaxMana() * mana_burn * stack * 0.01)
      local burned_mana = init_mana - target:GetMana()
      SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, target, burned_mana, caster)
    end

    if RandomFloat(0, 100) < self:GetSpecialValueFor("special_copy_chance") * stack then
      local illu_array = CreateIllusions(caster, caster, {
        outgoing_damage = self:GetSpecialValueFor("special_copy_outgoing") - 100,
        incoming_damage = self:GetSpecialValueFor("special_copy_incoming"),
        bounty_base = 0,
        bounty_growth = 0,
        duration = self:GetSpecialValueFor("special_copy_duration")
      }, 1, 64, false, true)
  
      for _,illu in pairs(illu_array) do
        local loc = target:GetAbsOrigin() + RandomVector(illu:Script_GetAttackRange())
        local direction = (loc - target:GetOrigin()):Normalized()
        illu:SetAbsOrigin(loc)
        illu:SetForwardVector(direction)
        illu:SetForceAttackTarget(target)
        FindClearSpaceForUnit(illu, loc, true)
        AddModifier(illu, caster, self, "icebreaker__modifier_illusion", {}, false)
      end
    end

    AddModifier(target, caster, self, "icebreaker__modifier_hypo", {stack = stack}, false)

    if target:HasModifier("icebreaker__modifier_frozen") == false then
      AddModifier(target, caster, self, "_modifier_silence", {
        duration = self:GetSpecialValueFor("special_silence_duration") * stack
      }, true)
    end
  end

-- EFFECTS