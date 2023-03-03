druid_1__root = class({})
LinkLuaModifier("druid_1_modifier_passive", "heroes/druid/druid_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_1_modifier_root", "heroes/druid/druid_1_modifier_root", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_1_modifier_mini_root", "heroes/druid/druid_1_modifier_mini_root", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_1_modifier_mini_root_aura_effect", "heroes/druid/druid_1_modifier_mini_root_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_root", "modifiers/_modifier_root", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_silence", "modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)

-- INIT

  druid_1__root.projectiles = {}

-- SPELL START

  function druid_1__root:GetIntrinsicModifierName()
    return "druid_1_modifier_passive"
  end

  function druid_1__root:OnAbilityPhaseStart()
    if IsServer() then
      if IsMetamorphosis("druid_4__form", self:GetCaster()) == false then
        self:GetCaster():EmitSound("Druid.Root.Cast")
        self:GetCaster():EmitSound("Hero_EarthShaker.Whoosh")
      end
    end

    return true
  end

  function druid_1__root:OnAbilityPhaseInterrupted()
    if IsServer() then
      if IsMetamorphosis("druid_4__form", self:GetCaster()) == false then
        self:GetCaster():StopSound("Druid.Root.Cast")
        self:GetCaster():StopSound("Hero_EarthShaker.Whoosh")
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

    self:PlayEfxStart()
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

  function druid_1__root:GetCastAnimation()
    if IsMetamorphosis("druid_4__form", self:GetCaster()) then return ACT_DOTA_CAST_ABILITY_4 end
    return ACT_DOTA_CAST_ABILITY_3
  end

  function druid_1__root:GetCastPoint()
    if IsMetamorphosis("druid_4__form", self:GetCaster()) then return 0.25 end
    return 0.5
  end

-- EFFECTS

  function druid_1__root:PlayEfxStart()
    local caster = self:GetCaster()
    local string = "particles/druid/druid_skill2_overgrowth.vpcf"
    local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(effect_cast, 0, caster:GetOrigin())

    if IsServer() then caster:EmitSound("Hero_EarthShaker.EchoSlamSmall") end
  end