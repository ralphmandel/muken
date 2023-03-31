druid_5__seed = class({})
LinkLuaModifier("druid_5_modifier_aura", "heroes/druid/druid_5_modifier_aura", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("druid_5_modifier_aura_effect", "heroes/druid/druid_5_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function druid_5__seed:OnOwnerSpawned()
    self:OnToggle()
  end

  function druid_5__seed:GetAOERadius()
    return self:GetSpecialValueFor("radius")
  end

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
    local heal = ExtraData.amount
    local base_stats = self:GetCaster():FindAbilityByName("base_stats")
    if base_stats then heal = heal * base_stats:GetHealPower() end
    if heal < 1 then return end

    caster:Heal(heal, self)
    self:PlayEfxHeal(hTarget)
  end

-- EFFECTS

  function druid_5__seed:PlayEfxHeal(target)
    local particle = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
    local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN, target)
    ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
    ParticleManager:SetParticleControl(effect, 1, target:GetOrigin())
    ParticleManager:ReleaseParticleIndex(effect)
  end