genuine_u__star = class({})
LinkLuaModifier("genuine_u_modifier_star", "heroes/team_moon/genuine/genuine_u_modifier_star", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function genuine_u__star:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    ChangeActivity(caster, "")

    local particle_cast = "particles/genuine/ult_caster/genuine_ult_caster.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:ReleaseParticleIndex(effect_cast)

    return true
  end

  function genuine_u__star:OnAbilityPhaseInterrupted()
    local caster = self:GetCaster()
    ChangeActivity(caster, "ti6")
  end

  function genuine_u__star:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local duration = self:GetSpecialValueFor("duration")
    if GameRules:IsDaytime() == false or GameRules:IsTemporaryNight() then
      duration = self:GetSpecialValueFor("duration_night")
    end

    ChangeActivity(caster, "ti6")
    if target:TriggerSpellAbsorb(self) then return end

    self:PlayEfxStart(caster, target)

    if target:IsIllusion() then target:ForceKill(false) return end
    AddModifier(target, caster, self, "genuine_u_modifier_star", {duration = duration + 0.1}, false)
  end

-- EFFECTS

  function genuine_u__star:PlayEfxStart(caster, target)
    local particle_cast = "particles/units/heroes/hero_terrorblade/terrorblade_sunder.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControlEnt(effect_cast, 0, caster, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
    ParticleManager:SetParticleControlEnt(effect_cast, 1, target, PATTACH_POINT_FOLLOW, "attach_hitloc", Vector(0,0,0), true)
    ParticleManager:SetParticleControl(effect_cast, 60, Vector(125, 0, 175))
    ParticleManager:SetParticleControl(effect_cast, 61, Vector(1, 0, 0))
    ParticleManager:ReleaseParticleIndex(effect_cast)

    if IsServer() then target:EmitSound("Hero_Terrorblade.DemonZeal.Cast") end
  end