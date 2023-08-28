hunter_2__aim = class({})
LinkLuaModifier("hunter_2_modifier_orb", "heroes/nature/hunter/hunter_2_modifier_orb", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("hunter_2_modifier_debuff", "heroes/nature/hunter/hunter_2_modifier_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "_modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function hunter_2__aim:GetIntrinsicModifierName()
    return "hunter_2_modifier_orb"
  end

  function hunter_2__aim:GetProjectileName()
    return "particles/econ/items/sniper/sniper_charlie/sniper_base_attack_charlie.vpcf"
  end

-- SPELL START

  function hunter_2__aim:OnOrbFire(keys)
    local caster = self:GetCaster()
    if IsServer() then caster:EmitSound("hero_viper.poisonAttack.Cast") end
  end

  function hunter_2__aim:OnOrbImpact(keys)
    local caster = self:GetCaster()
    local knockback_duration = self:GetSpecialValueFor("knockback_duration")
    local knockback_distance = self:GetSpecialValueFor("knockback_distance")
    local debuff_duration = self:GetSpecialValueFor("debuff_duration")

    keys.target:RemoveModifierByNameAndCaster("modifier_knockback", caster)

    local modifier = AddModifier(keys.target, self, "modifier_knockback", {
      center_x = caster:GetAbsOrigin().x + 1,
      center_y = caster:GetAbsOrigin().y + 1,
      center_z = caster:GetAbsOrigin().z,
      duration = knockback_duration,
      knockback_duration = CalcStatus(knockback_duration, caster, keys.target),
      knockback_distance = CalcStatus(knockback_distance, caster, keys.target),
      knockback_height = 0
    }, true)

    if IsServer() then self:PlayEfxHit(keys.target, modifier) end

    AddModifier(keys.target, self, "hunter_2_modifier_debuff", {duration = debuff_duration}, true)
  end

  function hunter_2__aim:OnOrbFail(keys)
  end

-- EFFECTS

  function hunter_2__aim:PlayEfxHit(target, modifier)
    if modifier then
      local string = "particles/units/heroes/hero_sniper/sniper_headshot_slow.vpcf"
      local particle = ParticleManager:CreateParticle(string, PATTACH_OVERHEAD_FOLLOW, target)
      ParticleManager:SetParticleControl(particle, 0, target:GetOrigin())
      modifier:AddParticle(particle, false, false, -1, false, false)
    end

    if IsServer() then target:EmitSound("Hero_Sniper.HeadShot") end
  end