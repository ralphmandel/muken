genuine_3__travel = class({})
LinkLuaModifier("genuine_3_modifier_travel", "heroes/moon/genuine/genuine_3_modifier_travel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_3_modifier_orb", "heroes/moon/genuine/genuine_3_modifier_orb", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_ban", "_modifiers/_modifier_ban", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function genuine_3__travel:Spawn()
    self:SetCurrentAbilityCharges(GENUINE_TRAVEL_STATE_IN)
  end

  function genuine_3__travel:GetBehavior()
    if self:GetCurrentAbilityCharges() == GENUINE_TRAVEL_STATE_OUT then
      return 137474607108
    end
    if self:GetCurrentAbilityCharges() == GENUINE_TRAVEL_STATE_IN then
      return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_DIRECTIONAL + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
    end
  end

  function genuine_3__travel:GetAbilityTextureName()
    if self:GetCurrentAbilityCharges() == GENUINE_TRAVEL_STATE_OUT then return "genuine_travel_2" end
    return "genuine_travel"
  end

  function genuine_3__travel:GetCastAnimation()
    if self:GetCurrentAbilityCharges() == GENUINE_TRAVEL_STATE_OUT then return ACT_DOTA_TELEPORT_END end
    return ACT_DOTA_SPAWN
  end

  function genuine_3__travel:GetAOERadius()
    return self:GetSpecialValueFor("projectile_distance")
  end


-- SPELL START

  function genuine_3__travel:OnSpellStart()
    local caster = self:GetCaster()

    if self:GetCurrentAbilityCharges() == GENUINE_TRAVEL_STATE_OUT then
      self:DestroyOrb()
      return
    end

    if self:GetCurrentAbilityCharges() == GENUINE_TRAVEL_STATE_IN then
      local point = self:GetCursorPosition()
      local projectile_direction = point - caster:GetOrigin()
      projectile_direction = Vector(projectile_direction.x, projectile_direction.y, 0):Normalized()
  
      self.projectile = ProjectileManager:CreateLinearProjectile({
        Source = caster,
        Ability = self,
        vSpawnOrigin = caster:GetOrigin(),
        
        bDeleteOnHit = false,
        
        iUnitTargetTeam = self:GetAbilityTargetTeam(),
        iUnitTargetType = self:GetAbilityTargetType(),
        iUnitTargetFlags = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,
        
        EffectName = "particles/econ/items/puck/puck_merry_wanderer/puck_illusory_orb_merry_wanderer.vpcf",
        fDistance = self:GetSpecialValueFor("projectile_distance"),
        fStartRadius = self:GetSpecialValueFor("projectile_radius"),
        fEndRadius =self:GetSpecialValueFor("projectile_radius"),
        vVelocity = projectile_direction * self:GetSpecialValueFor("projectile_speed"),
    
        bReplaceExisting = false,
        
        bProvidesVision = true,
        iVisionRadius = self:GetSpecialValueFor("vision_radius"),
        iVisionTeamNumber = caster:GetTeamNumber(),
      })
  
      local modifier_thinker = CreateModifierThinker(
        caster, self, "genuine_3_modifier_orb", {duration = 20},
        caster:GetOrigin(), caster:GetTeamNumber(), false		
      )
  
      local modifier = modifier_thinker:FindModifierByName("genuine_3_modifier_orb")
  
      local extraData = {}
      extraData.damage = self:GetSpecialValueFor("damage")
      extraData.location = caster:GetOrigin()
      extraData.time = GameRules:GetGameTime()
      extraData.modifier = modifier
      self.projectileData = extraData
      self.point = caster:GetOrigin()

      ProjectileManager:ProjectileDodge(caster)
  
      self:SetCurrentAbilityCharges(GENUINE_TRAVEL_STATE_OUT)
      self:EndCooldown()
      self:StartCooldown(0.2)
    end
  end

  function genuine_3__travel:OnProjectileThinkHandle(proj)
    local caster = self:GetCaster()
    local location = ProjectileManager:GetLinearProjectileLocation(proj)
    self.projectileData.location = location
    self.projectileData.modifier:GetParent():SetOrigin(location)
    caster:SetOrigin(location)
  end

  function genuine_3__travel:OnProjectileHitHandle(target, location, proj)
    if not target then self:DestroyOrb() return true end
    local caster = self:GetCaster()

    ApplyDamage({
      victim = target,
      attacker = caster,
      damage = self.projectileData.damage,
      damage_type = self:GetAbilityDamageType(),
      ability = self,
    })

    self:PlayEfxHit(target)
    return false
  end

  function genuine_3__travel:DestroyOrb()
    local caster = self:GetCaster()

    if self.projectileData then
      local traveled_distance = (self.point - self.projectileData.location):Length2D()
      local silence_min = self:GetSpecialValueFor("silence_min")
      local silence_duration = silence_min + (traveled_distance / self:GetSpecialValueFor("silence_mult"))
  
      local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(), caster:GetOrigin(), nil, self:GetSpecialValueFor("silence_radius"),
        self:GetAbilityTargetTeam(), self:GetAbilityTargetType(),
        self:GetAbilityTargetFlags(), 0, false
      )
  
      for _,enemy in pairs(enemies) do
        if IsServer() then enemy:EmitSound("Hero_Puck.EtherealJaunt") end
        AddModifier(enemy, self, "_modifier_silence", {duration = silence_duration}, true)
      end

      caster:RemoveModifierByName("genuine_3_modifier_travel")
      self.projectileData.modifier:GetParent():StopSound("Hero_Puck.Illusory_Orb")
      self.projectileData.modifier:Destroy()
    end

    if self.projectile then ProjectileManager:DestroyLinearProjectile(self.projectile) end

    self.projectileData = nil
    self.projectile = nil

    self:SetCurrentAbilityCharges(GENUINE_TRAVEL_STATE_IN)
    self:StartCooldown(self:GetEffectiveCooldown(self:GetLevel()))
    caster:StartGesture(ACT_DOTA_TELEPORT_END)
  end

-- EFFECTS

  function genuine_3__travel:PlayEfxHit(target)
    local particle_cast = "particles/units/heroes/hero_puck/puck_orb_damage.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:ReleaseParticleIndex(effect_cast)

    if IsServer() then target:EmitSound("Hero_Puck.IIllusory_Orb_Damage") end
  end