genuine_5__nightfall = class({})
LinkLuaModifier("genuine_5_modifier_channeling", "heroes/team_moon/genuine/genuine_5_modifier_channeling", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

  genuine_5__nightfall.projectiles = {}

  function genuine_5__nightfall:OnOwnerSpawned()
    self:SetActivated(true)
  end

  function genuine_5__nightfall:GetAbilityDamageType()
    if self:GetSpecialValueFor("special_pure_dmg") == 1 then return DAMAGE_TYPE_PURE end
    return DAMAGE_TYPE_MAGICAL
  end

-- SPELL START

  function genuine_5__nightfall:OnSpellStart()
    local caster = self:GetCaster()
    local time = self:GetChannelTime()
    local gesture_time = 0.4
    local rate = 1 / (time / gesture_time)

    caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, rate)
    AddModifier(caster, caster, self, "genuine_5_modifier_channeling", {}, false)
    self:SetActivated(false)
    self:EndCooldown()

    self:PlayEfxChannel(self:GetCursorPosition(), time * 100)
  end

  function genuine_5__nightfall:OnChannelFinish(bInterrupted)
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local channel_pct = (GameRules:GetGameTime() - self:GetChannelStartTime()) / self:GetChannelTime()
    channel_pct = (channel_pct * 0.8) + 0.2

    Timers:CreateTimer((0.1), function()
      caster:FadeGesture(ACT_DOTA_CAST_ABILITY_2)
    end)

    caster:RemoveModifierByName("genuine_5_modifier_channeling")
    self:SetActivated(true)
    self:StartCooldown(self:GetEffectiveCooldown(self:GetLevel()))

    local projectile_name = "particles/genuine/genuine_powershoot/genuine_spell_powershot_ti6.vpcf"
    local damage_reduction = 1 - (self:GetSpecialValueFor("damage_reduction") * 0.01)
    local projectile_direction = point-caster:GetOrigin()
    projectile_direction.z = 0
    projectile_direction = projectile_direction:Normalized()

    local fDistance = self:GetCastRange(caster:GetAbsOrigin(), nil) * channel_pct
    if fDistance < 500 then fDistance = 500 end

    local projectile = ProjectileManager:CreateLinearProjectile({
      Source = caster,
      Ability = self,
      vSpawnOrigin = caster:GetAbsOrigin(),
      
      iUnitTargetTeam = self:GetAbilityTargetTeam(),
      iUnitTargetType = self:GetAbilityTargetType(),
      iUnitTargetFlags = self:GetAbilityTargetFlags(),

      EffectName = projectile_name,
      fDistance = fDistance,
      fStartRadius = self:GetSpecialValueFor("arrow_width"),
      fEndRadius = self:GetSpecialValueFor("arrow_width"),
      vVelocity = projectile_direction * self:GetSpecialValueFor("arrow_speed"),

      bProvidesVision = true,
      iVisionRadius = self:GetSpecialValueFor("vision_radius"),
      iVisionTeamNumber = caster:GetTeamNumber(),
    })

    local knockback = self:GetSpecialValueFor("special_bash_power") * channel_pct

    self.projectiles[projectile] = {}
    self.projectiles[projectile].damage = self:GetSpecialValueFor("damage") * channel_pct
    self.projectiles[projectile].reduction = damage_reduction
    self.projectiles[projectile].knockbackProperties = {
      center_x = caster:GetAbsOrigin().x + 1, center_y = caster:GetAbsOrigin().y + 1, center_z = caster:GetAbsOrigin().z,
      knockback_height = 0, duration = knockback / 2000, knockback_duration = knockback / 2000, knockback_distance = knockback
    }

    self:StopEfxChannel()
  end

  function genuine_5__nightfall:OnProjectileHitHandle(target, location, handle)
    local caster = self:GetCaster()

    if not target then
      self.projectiles[handle] = nil

      local vision_radius = self:GetSpecialValueFor("vision_radius")
      local vision_duration = self:GetSpecialValueFor("vision_duration")
      AddFOWViewer(caster:GetTeamNumber(), location, vision_radius, vision_duration, false)

      return
    end

    local data = self.projectiles[handle]
    local damage = data.damage

    if data.knockbackProperties.knockback_distance > 0 then
      local properties = data.knockbackProperties
      properties.duration = CalcStatus(properties.duration, caster, target)
      AddModifier(target, caster, nil, "modifier_knockback", properties, false)
      AddModifier(target, caster, self, "_modifier_percent_movespeed_debuff", {
        duration = properties.duration * 4, percent = 100
      }, false)
    end

    if IsServer() then target:EmitSound("Hero_Windrunner.PowershotDamage") end

    ApplyDamage({
      victim = target, attacker = caster,
      ability = self, damage = damage,
      damage_type = self:GetAbilityDamageType()
    })

    if IsValidEntity(target) then
      if target:IsAlive() == false then
        IncreaseMana(caster, self:GetSpecialValueFor("special_mana") * BaseStats(caster):GetHealPower())
      end
    end

    data.damage = damage * data.reduction
  end

  function genuine_5__nightfall:OnProjectileThink(location)
    local tree_width = self:GetSpecialValueFor("tree_width")
    GridNav:DestroyTreesAroundPoint(location, tree_width, false)	
  end

  function genuine_5__nightfall:GetChannelTime()
    local channel = self:GetCaster():FindAbilityByName("_channel")
    local channel_time = self:GetSpecialValueFor("channel_time")
    return channel_time * (1 - (channel:GetLevel() * channel:GetSpecialValueFor("channel") * 0.01))
  end

-- EFFECTS

  function genuine_5__nightfall:PlayEfxChannel(point, time)
    local caster = self:GetCaster()
    local particle_cast = "particles/genuine/genuine_powershoot/genuine_powershot_channel_combo_v2.vpcf"
    local direction = point - caster:GetAbsOrigin()

    if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, true) end
    self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(self.effect_cast, 0, caster:GetOrigin())
    ParticleManager:SetParticleControlForward(self.effect_cast, 0, direction:Normalized())
    ParticleManager:SetParticleControl(self.effect_cast, 1, caster:GetOrigin())
    ParticleManager:SetParticleControlForward(self.effect_cast, 1, direction:Normalized())
    ParticleManager:SetParticleControl(self.effect_cast, 10, Vector(math.floor(time), 0, 0))

    if IsServer() then EmitSoundOnLocationForAllies(caster:GetOrigin(), "Ability.PowershotPull.Lyralei", caster) end
  end

  function genuine_5__nightfall:StopEfxChannel()
    local caster = self:GetCaster()
    if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, false) end

    if IsServer() then
      caster:StopSound("Ability.PowershotPull.Lyralei")
      caster:EmitSound("Ability.Powershot.Alt")
    end
  end