dasdingo_u__curse = class({})
LinkLuaModifier("dasdingo_u_modifier_curse", "heroes/team_nature/dasdingo/dasdingo_u_modifier_curse", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_fear", "_modifiers/_modifier_fear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_fear_status_efx", "_modifiers/_modifier_fear_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function dasdingo_u__curse:GetAOERadius()
    return self:GetSpecialValueFor("radius")
  end

-- SPELL START

  function dasdingo_u__curse:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local fear_duration = self:GetSpecialValueFor("fear_duration")

    local enemies = FindUnitsInRadius(
      caster:GetTeamNumber(), point, nil, self:GetSpecialValueFor("radius"),
      self:GetAbilityTargetTeam(), self:GetAbilityTargetType(),
      self:GetAbilityTargetFlags(), 0, false
    )

    for _,enemy in pairs(enemies) do
      AddModifier(enemy, caster, self, "dasdingo_u_modifier_curse", {}, false)

      if enemy:IsMagicImmune() == false then
        AddModifier(enemy, caster, self, "_modifier_fear", {
          duration = fear_duration, special = 2, x = point.x, y = point.y, z = point.z
        }, true)
      end
    end

    self:PlayEfxStart(point, fear_duration)
  end

-- EFFECTS

  function dasdingo_u__curse:PlayEfxStart(point, fow_duration)
    local caster = self:GetCaster()
    local radius = self:GetAOERadius()

    local particle = "particles/units/heroes/hero_dark_willow/dark_willow_wisp_spell.vpcf"
    local effect = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(effect, 0, point)
    ParticleManager:SetParticleControl(effect, 1, Vector(radius, 2, radius * 2))
    ParticleManager:SetParticleControl(effect, 60, Vector(25, 5, 15))
    ParticleManager:SetParticleControl(effect, 61, Vector(1, 0, 0))
    ParticleManager:ReleaseParticleIndex(effect)

    if IsServer() then
      EmitSoundOnLocationWithCaster(point, "Hero_Dazzle.BadJuJu.Cast", caster)
      EmitSoundOnLocationWithCaster(point, "Hero_Oracle.FalsePromise.Damaged", caster)
    end

    AddFOWViewer(caster:GetTeamNumber(), point, radius, fow_duration, false)
  end