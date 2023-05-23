bloodstained_5__tear = class({})
LinkLuaModifier("bloodstained_5_modifier_tear", "heroes/team_death/bloodstained/bloodstained_5_modifier_tear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_5_modifier_blood", "heroes/team_death/bloodstained/bloodstained_5_modifier_blood", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function bloodstained_5__tear:Spawn()
    self:SetCurrentAbilityCharges(1)
  end

  function bloodstained_5__tear:OnOwnerSpawned()
    self:SetCurrentAbilityCharges(1)
  end

  function bloodstained_5__tear:GetAbilityTextureName()
    if self:GetCurrentAbilityCharges() == 1 then return "bloodstained_tear" end
    if self:GetCurrentAbilityCharges() == 2 then return "bloodstained_consume" end
  end

  function bloodstained_5__tear:GetBehavior()
    if self:GetCurrentAbilityCharges() == 1 then return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE end
    if self:GetCurrentAbilityCharges() == 2 then return DOTA_ABILITY_BEHAVIOR_NO_TARGET end
  end

-- SPELL START

  function bloodstained_5__tear:OnSpellStart()
    local caster = self:GetCaster()
    local init_loss = self:GetSpecialValueFor("special_init_loss")

    if self:GetCurrentAbilityCharges() == 1 then
      caster:AddNewModifier(caster, self, "bloodstained_5_modifier_tear", {})
      self:PlayEfxShake(init_loss)
      self:EndCooldown()
      self:StartCooldown(1)
      self:SetCurrentAbilityCharges(2)
      return
    end

    if self:GetCurrentAbilityCharges() == 2 then
      caster:RemoveModifierByName("bloodstained_5_modifier_tear")
      self:SetCurrentAbilityCharges(1)
    end
  end

  function bloodstained_5__tear:GetAOERadius()
    return self:GetSpecialValueFor("radius")
  end

-- EFFECTS

  function bloodstained_5__tear:PlayEfxShake(init_loss)
    local caster = self:GetCaster()
    local string_3 = "particles/osiris/poison_alt/osiris_poison_splash_shake.vpcf"
    local particle_3 = ParticleManager:CreateParticle(string_3, PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(particle_3, 0, caster:GetOrigin())
    ParticleManager:SetParticleControl(particle_3, 1, Vector(init_loss, 0, 0))
  end