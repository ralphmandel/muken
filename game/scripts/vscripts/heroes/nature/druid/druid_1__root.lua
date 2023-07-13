druid_1__root = class({})
LinkLuaModifier("druid_1_modifier_passive", "heroes/nature/druid/druid_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_1_modifier_root", "heroes/nature/druid/druid_1_modifier_root", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_1_modifier_root_aura_effect", "heroes/nature/druid/druid_1_modifier_root_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_1_modifier_mini_root", "heroes/nature/druid/druid_1_modifier_mini_root", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_root", "_modifiers/_modifier_root", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_silence", "_modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_disarm", "_modifiers/_modifier_disarm", LUA_MODIFIER_MOTION_NONE)

-- INIT

  druid_1__root.projectiles = {}

  function druid_1__root:GetIntrinsicModifierName()
    return "druid_1_modifier_passive"
  end

  function druid_1__root:GetAOERadius()
    return self:GetSpecialValueFor("special_elden_radius")
  end

  function druid_1__root:GetCastAnimation()
    if IsMetamorphosis("druid_4__form", self:GetCaster()) == 1 then return ACT_DOTA_CAST_ABILITY_4 end
    return ACT_DOTA_CAST_ABILITY_3  
  end

  function druid_1__root:GetCastPoint()
    if IsMetamorphosis("druid_4__form", self:GetCaster()) == 1 then return 0.25 end
    return 0.5
  end

-- SPELL START



  function druid_1__root:OnAbilityPhaseStart()
    local caster = self:GetCaster()

    -- if not self.delete then self.delete = 1499 end
    -- caster:FadeGesture(self.delete)
    -- self.delete = self.delete + 1
    -- caster:StartGesture(self.delete)
    -- GameRules:SendCustomMessage("gesture: "..self.delete,-1,0)

    if IsServer() then
      if IsMetamorphosis("druid_4__form", self:GetCaster()) == 0 then
        caster:EmitSound("Druid.Root.Cast")
        caster:EmitSound("Hero_EarthShaker.Whoosh")
      end
    end

    return true
  end

  function druid_1__root:OnAbilityPhaseInterrupted()
    local caster = self:GetCaster()

    if IsServer() then
      if IsMetamorphosis("druid_4__form", self:GetCaster()) == 0 then
        caster:StopSound("Druid.Root.Cast")
        caster:StopSound("Hero_EarthShaker.Whoosh")
      end
    end
  end

  function druid_1__root:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    local direction = point - caster:GetOrigin()
    direction.z = 0
    direction = direction:Normalized()

    local projectile = ProjectileManager:CreateLinearProjectile({
      Source = caster,
      Ability = self,
      vSpawnOrigin = caster:GetAbsOrigin(),
      
      bDeleteOnHit = true,
      
      iUnitTargetTeam = self:GetAbilityTargetTeam(),
      iUnitTargetFlags = self:GetAbilityTargetFlags(),
      iUnitTargetType = self:GetAbilityTargetType(),
      
      EffectName = "",
      fDistance = self:GetSpecialValueFor("distance"),
      fStartRadius = self:GetSpecialValueFor("path_radius"),
      fEndRadius = self:GetSpecialValueFor("path_radius"),
      vVelocity = direction * self:GetSpecialValueFor("creation_speed"),
      bProvidesVision = false,
      iVisionRadius = 0,
      iVisionTeamNumber = caster:GetTeamNumber()
    })

    self.projectiles[projectile] = {}
		self.projectiles[projectile].origin = caster:GetOrigin()
		self.projectiles[projectile].location = caster:GetOrigin()

    self:PerformSuperRoot()
    self:PlayEfxStart()
  end

  function druid_1__root:PerformSuperRoot()
    local caster = self:GetCaster()
    local elden_radius = self:GetSpecialValueFor("special_elden_radius")
    local elden_duration = self:GetSpecialValueFor("special_elden_duration")
    local elden_damage = self:GetSpecialValueFor("special_elden_damage")
    if elden_radius == 0 then return end

    self:PlayEfxSuperRoot(caster)

    local enemies = FindUnitsInRadius(
      caster:GetTeamNumber(), caster:GetOrigin(), nil, elden_radius,
      DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
      DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false
    )

    for _,enemy in pairs(enemies) do
      local multiplier = 1 - ((CalcDistanceBetweenEntityOBB(caster, enemy) / elden_radius) * 0.5)
      AddModifier(enemy, caster, self, "_modifier_root", {
        duration = elden_duration * multiplier, effect = 8
      }, true)

      ApplyDamage({
        attacker = caster, victim = enemy,
        damage = elden_damage * multiplier,
        damage_type = self:GetAbilityDamageType(),
        ability = self
      })
    end
  end

  function druid_1__root:OnProjectileHitHandle(target, location, handle)
    if not target then self.projectiles[handle] = nil end
  end

  function druid_1__root:OnProjectileThinkHandle(id)
    if self.projectiles[id] == nil then return end
    local proj_loc = ProjectileManager:GetLinearProjectileLocation(id)

    local distance = (proj_loc - self.projectiles[id].location):Length2D()
    local radius = self:GetSpecialValueFor("path_radius")
    local bush_duration = self:GetSpecialValueFor("bush_duration")
    local bonus_duration = ((proj_loc - self.projectiles[id].origin):Length2D() / 500) + RandomFloat(-bush_duration * 0.2, bush_duration * 0.2)
    bush_duration = bush_duration + bonus_duration

    if distance >= radius / 3 then
      self:CreateBush(self:RandomizeLocation(self.projectiles[id].origin, proj_loc, radius), bush_duration, "druid_1_modifier_root")
      self.projectiles[id].location = proj_loc
    end
  end

  function druid_1__root:RandomizeLocation(origin, point, radius)
    local distance = RandomInt(-radius, radius)
    local cross = CrossVectors(origin - point, Vector(0, 0, 1)):Normalized() * distance
    return point + cross
  end

  function druid_1__root:CreateBush(point, duration, string)
    local caster = self:GetCaster()
    CreateModifierThinker(caster, self, string, {duration = duration}, point, caster:GetTeamNumber(), false)
  end

-- EFFECTS

  function druid_1__root:PlayEfxStart()
    local caster = self:GetCaster()
    local string = "particles/druid/druid_skill2_overgrowth.vpcf"
    local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(effect_cast, 0, caster:GetOrigin())

    if IsServer() then caster:EmitSound("Hero_EarthShaker.EchoSlamSmall") end
  end

  function druid_1__root:PlayEfxSuperRoot(target)
    local particle = "particles/econ/items/treant_protector/treant_ti10_immortal_head/treant_ti10_immortal_overgrowth_cast.vpcf"
    local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, target)
    ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
    ParticleManager:ReleaseParticleIndex(effect)

    if IsServer() then target:EmitSound("Druid.EldenTree.Cast") end
  end