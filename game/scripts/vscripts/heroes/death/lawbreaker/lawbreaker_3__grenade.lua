lawbreaker_3__grenade = class({})
LinkLuaModifier("lawbreaker_3_modifier_detonate", "heroes/death/lawbreaker/lawbreaker_3_modifier_detonate", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("lawbreaker_3_modifier_grenade", "heroes/death/lawbreaker/lawbreaker_3_modifier_grenade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_blind", "_modifiers/_modifier_blind", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_blind_stack", "_modifiers/_modifier_blind_stack", LUA_MODIFIER_MOTION_NONE)

-- INIT

  lawbreaker_3__grenade.projectiles = {}

  function lawbreaker_3__grenade:GetAOERadius()
    return self:GetSpecialValueFor("radius")
  end

-- SPELL START

  function lawbreaker_3__grenade:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    if caster:HasModifier("lawbreaker_2_modifier_combo") then return false end
    if IsServer() then caster:EmitSound("Hero_Muerta.PreAttack") end

    caster:AddActivityModifier("aggressive")
    caster:StartGesture(ACT_DOTA_CAST_ABILITY_5)

    return true
  end

	function lawbreaker_3__grenade:OnSpellStart()
		local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local spawn_origin = caster:GetOrigin() + (caster:GetForwardVector():Normalized() * 100)
    local distance = (spawn_origin - point):Length2D()
    if distance < 200 then
      point = spawn_origin + (caster:GetForwardVector():Normalized() * 200)
      point.z = self:GetCursorPosition().z
      distance = (spawn_origin - point):Length2D()
    end

    local direction = point - spawn_origin
    direction.z = 0
    direction = direction:Normalized()

    caster:ClearActivityModifiers()

    local projectile = ProjectileManager:CreateLinearProjectile({
      Source = caster,
      Ability = self,
      vSpawnOrigin = spawn_origin,
      
      bDeleteOnHit = false,
      
      iUnitTargetTeam = self:GetAbilityTargetTeam(),
      iUnitTargetFlags = self:GetAbilityTargetFlags(),
      iUnitTargetType = self:GetAbilityTargetType(),
      
      EffectName = "",
      fDistance = distance,
      fStartRadius = self:GetSpecialValueFor("proj_radius"),
      fEndRadius = self:GetSpecialValueFor("proj_radius"),
      vVelocity = direction * self:GetSpecialValueFor("proj_speed"),
  
      bProvidesVision = true,
      iVisionRadius = self:GetSpecialValueFor("proj_radius"),
      iVisionTeamNumber = caster:GetTeamNumber()
    })

    self.projectiles[projectile] = {}
    if IsServer() then self.projectiles[projectile].pfx = self:PlayEfxStart(spawn_origin, point) end
	end

  function lawbreaker_3__grenade:OnProjectileHitHandle(target, loc, handle)
    local caster = self:GetCaster()
    local delay = self:GetSpecialValueFor("delay")

    if target then
      if target:IsMagicImmune() == false then
        AddModifier(target, caster, self, "lawbreaker_3_modifier_grenade", {
          duration = 2
        }, true)
      end
    else
      CreateModifierThinker(
        caster, self, "lawbreaker_3_modifier_detonate",
        {id = handle}, loc,
        caster:GetTeamNumber(), false
      )
    end
  end

-- EFFECTS

  function lawbreaker_3__grenade:PlayEfxStart(origin, point)
    local caster = self:GetCaster()
    local string = "particles/lawbreaker/grenade/lawbreaker_grenade_model.vpcf"
    local particle = ParticleManager:CreateParticle(string, PATTACH_WORLDORIGIN, nil)
    origin.z = origin.z + 75

    ParticleManager:SetParticleControl(particle, 0, origin)
    ParticleManager:SetParticleControl(particle, 1, Vector(self:GetSpecialValueFor("proj_speed"), 0, 0))
    ParticleManager:SetParticleControl(particle, 5, point)
    ParticleManager:SetParticleControl(particle, 10, Vector(self:GetAOERadius(), 0, 0))

    if IsServer() then
      caster:EmitSound("Hero_Muerta.DeadShot.Cast")
      caster:EmitSound("Hero_Sniper.ConcussiveGrenade.Cast")
    end

    return particle
  end