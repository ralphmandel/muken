templar_5__reborn = class({})
LinkLuaModifier("templar_5_modifier_reborn", "heroes/sun/templar/templar_5_modifier_reborn", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function templar_5__reborn:CastFilterResultLocation(vLocation)
    local caster = self:GetCaster()

    local allies = FindUnitsInRadius(
      caster:GetTeamNumber(), vLocation, nil, 200,
      self:GetAbilityTargetTeam(), self:GetAbilityTargetType(),
      self:GetAbilityTargetFlags(), 0, false
    )

    for _,ally in pairs(allies) do
      if ally:IsAlive() == false and ally:IsReincarnating() == false 
      and ally:GetTimeUntilRespawn() > self:GetCastPoint() then
        return UF_SUCCESS
      end
    end

    return UF_FAIL_CUSTOM
  end

  function templar_5__reborn:GetCustomCastErrorLocation(vLocation)
    return "NO DEAD ALLIED HEROES FOUND"
  end

-- SPELL START

  function templar_5__reborn:OnAbilityPhaseStart()
    local caster = self:GetCaster()

    local allies = FindUnitsInRadius(
      caster:GetTeamNumber(), self:GetCursorPosition(), nil, 210,
      self:GetAbilityTargetTeam(), self:GetAbilityTargetType(),
      self:GetAbilityTargetFlags(), FIND_CLOSEST, false
    )

    for _,ally in pairs(allies) do
      if ally:IsAlive() == false and ally:IsReincarnating() == false 
      and ally:GetTimeUntilRespawn() > self:GetCastPoint() then
        self.target = ally
        if IsServer() then self:PlayEfxPre(self.target:GetOrigin()) end
        return true
      end
    end

    return false
  end

  function templar_5__reborn:OnAbilityPhaseInterrupted()
    local caster = self:GetCaster()
    if IsServer() then self:StopEfx() end
  end

  function templar_5__reborn:OnSpellStart()
    if self.target:IsAlive() then
      if IsServer() then self:StopEfx() end
      return
    end
    
    self.target:RespawnHero(false, false)
    self.target:SetHealth(self.target:GetMaxHealth() * self:GetSpecialValueFor("percent") * 0.01)
    self.target:SetMana(self.target:GetMaxMana() * self:GetSpecialValueFor("percent") * 0.01)
    FindClearSpaceForUnit(self.target, self:GetCursorPosition(), false)

    if IsServer() then self:PlayEfxStart(self:GetCursorPosition()) end
  end

-- EFFECTS

  function templar_5__reborn:StopEfx()
    local caster = self:GetCaster()

    if self.efx_pre then
      ParticleManager:DestroyParticle(self.efx_pre, true)
      ParticleManager:ReleaseParticleIndex(self.efx_pre)
      self.efx_pre = nil
    end

    if IsServer() then caster:StopSound("Druid.Channel") end
  end

  function templar_5__reborn:PlayEfxPre(loc)
    self:StopEfx()
    
    local caster = self:GetCaster()
    local particle_pre = "particles/econ/events/ti10/aegis_lvl_1000_ambient_ti10.vpcf"
    self.efx_pre = ParticleManager:CreateParticle(particle_pre, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(self.efx_pre, 0, loc)

    if IsServer() then caster:EmitSound("Druid.Channel") end
  end

  function templar_5__reborn:PlayEfxStart(loc)
    self:StopEfx()
    
    local caster = self:GetCaster()
    local particle_reborn = "particles/items_fx/aegis_respawn_timer.vpcf"
    local efx_reborn = ParticleManager:CreateParticle(particle_reborn, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(efx_reborn, 0, loc)
    ParticleManager:SetParticleControl(efx_reborn, 1, Vector(0, 0, 0))

    if IsServer() then self.target:EmitSound("Aegis.Expire") end
  end