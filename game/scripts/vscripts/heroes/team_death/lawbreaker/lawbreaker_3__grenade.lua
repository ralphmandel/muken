lawbreaker_3__grenade = class({})
LinkLuaModifier("lawbreaker_3_modifier_grenade", "heroes/team_death/lawbreaker/lawbreaker_3_modifier_grenade", LUA_MODIFIER_MOTION_NONE)
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
    local direction = self:GetCursorPosition() - caster:GetOrigin()
    local distance = (caster:GetOrigin() - self:GetCursorPosition()):Length2D()
    direction.z = 0
    direction = direction:Normalized()

    caster:ClearActivityModifiers()

    local projectile = ProjectileManager:CreateLinearProjectile({
      Source = caster,
      Ability = self,
      vSpawnOrigin = caster:GetOrigin(),
      
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
    if IsServer() then self.projectiles[projectile].pfx = self:PlayEfxStart(caster:GetOrigin(), self:GetCursorPosition()) end
	end

  function lawbreaker_3__grenade:OnProjectileHitHandle(target, loc, handle)
    local caster = self:GetCaster()
    if target then
      AddModifier(target, caster, self, "lawbreaker_3_modifier_grenade", {
        duration = self:GetSpecialValueFor("duration")
      }, true)
    else
      AddFOWViewer(caster:GetTeamNumber(), loc, self:GetAOERadius(), 2, false)
      GridNav:DestroyTreesAroundPoint(loc, self:GetAOERadius(), false)	
      self:StopEfxStart(self.projectiles[handle].pfx, loc)
      self.projectiles[handle] = nil

      local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(), loc, nil, self:GetAOERadius(),
        self:GetAbilityTargetTeam(), self:GetAbilityTargetType(),
        self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false
      )

      for _,enemy in pairs(enemies) do
        AddModifier(enemy, caster, self, "lawbreaker_3_modifier_grenade", {
          duration = self:GetSpecialValueFor("duration")
        }, true)

        if IsServer() then enemy:EmitSound("Hero_Muerta.DeadShot.Damage") end
  
        ApplyDamage({
          victim = enemy, attacker = caster, ability = self,
          damage = self:GetSpecialValueFor("damage"),
          damage_type = self:GetAbilityDamageType()
        })
      end
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

    if IsServer() then
      caster:EmitSound("Hero_Muerta.DeadShot.Cast")
      caster:EmitSound("Hero_Sniper.ConcussiveGrenade.Cast")
    end

    return particle
  end

  function lawbreaker_3__grenade:StopEfxStart(pfx, loc)
    local caster = self:GetCaster()

    if pfx then ParticleManager:DestroyParticle(pfx, false) end
    if IsServer() then EmitSoundOnLocationWithCaster(loc, "Hero_Sniper.ConcussiveGrenade", caster) end
  end