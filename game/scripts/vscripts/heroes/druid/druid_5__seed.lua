druid_5__seed = class({})
LinkLuaModifier("druid_5_modifier_aura", "heroes/druid/druid_5_modifier_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_5_modifier_aura_effect", "heroes/druid/druid_5_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function druid_5__seed:OnOwnerSpawned()
    self:OnToggle()
  end

  function druid_5__seed:GetAOERadius()
    return self:GetSpecialValueFor("radius")
  end

-- SPELL START

  function druid_5__seed:OnToggle()
    local caster = self:GetCaster()

    if self:GetToggleState() then
      caster:AddNewModifier(caster, self, "druid_5_modifier_aura", {})
    else
      caster:RemoveModifierByName("druid_5_modifier_aura")
    end
  end

  function druid_5__seed:OnProjectileHit_ExtraData(hTarget, vLocation, ExtraData)
    if not hTarget then return end
    local caster = self:GetCaster()
    local heal = ExtraData.amount * BaseStats(caster):GetHealPower()
    if heal < 1 then return end

    caster:Heal(heal, self)
    self:PlayEfxHeal(hTarget)
  end

  function druid_5__seed:CreateSeed(target)
    local caster = self:GetCaster()
    local source = nil

    self:PlayEfxSeed(target)
    if target:IsBaseNPC() then source = target end

    ProjectileManager:CreateTrackingProjectile({
      Target = caster,
      Source = source,
      vSourceLoc = target:GetAbsOrigin(),
      Ability = self,
      EffectName = "particles/druid/druid_ult_projectile.vpcf",
      iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
      iMoveSpeed = self:GetSpecialValueFor("seed_speed"),
      bReplaceExisting = false,
      bProvidesVision = true,
      iVisionRadius = 75,
      iVisionTeamNumber = caster:GetTeamNumber(),
      ExtraData = {amount = self:GetSpecialValueFor("seed_base_heal")},
      bDodgeable = false
    })
  end

-- EFFECTS

  function druid_5__seed:PlayEfxHeal(target)
    local particle = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
    local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, target)
    ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
    ParticleManager:SetParticleControl(effect, 1, target:GetOrigin())
    ParticleManager:ReleaseParticleIndex(effect)
  end

  function druid_5__seed:PlayEfxSeed(target)
    local string = "particles/units/heroes/hero_treant/treant_leech_seed_damage_pulse.vpcf"
    local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 0, target:GetOrigin())
    ParticleManager:ReleaseParticleIndex(particle)
  
    if IsServer() then target:EmitSound("Hero_Treant.LeechSeed.Tick") end
  end