baldur_5__fire = class({})
LinkLuaModifier("baldur_5_modifier_fire", "heroes/sun/baldur/baldur_5_modifier_fire", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function baldur_5__fire:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    caster:StartGesture(ACT_DOTA_VERSUS)

    return true
  end

  function baldur_5__fire:OnAbilityPhaseInterrupted()
    local caster = self:GetCaster()
    caster:FadeGesture(ACT_DOTA_VERSUS)
  end

  function baldur_5__fire:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()
    local point = self:GetCursorPosition()
    if target then point = target:GetOrigin() end

    Timers:CreateTimer(0.5, function()
      caster:FadeGesture(ACT_DOTA_VERSUS)
    end)

    local projectile_direction = point - caster:GetOrigin()
    projectile_direction.z = 0
    projectile_direction = projectile_direction:Normalized()

    ProjectileManager:CreateLinearProjectile({
      Source = caster,
      Ability = self,
      vSpawnOrigin = caster:GetAbsOrigin(),
      bDeleteOnHit = false,
      iUnitTargetTeam = self:GetAbilityTargetTeam(),
      iUnitTargetType = self:GetAbilityTargetType(),
      iUnitTargetFlags = self:GetAbilityTargetFlags(),
      
      EffectName = "particles/units/heroes/hero_dragon_knight/dragon_knight_breathe_fire.vpcf",
      fDistance = self:GetSpecialValueFor("range"),
      fStartRadius = 150,
      fEndRadius = 250,
      vVelocity =  projectile_direction * 1050,
    })

    if IsServer() then caster:EmitSound("Hero_DragonKnight.BreathFire") end
  end

  function baldur_5__fire:OnProjectileHit(target, location)
    if not target then return end
    local caster = self:GetCaster()

    ApplyDamage({
      victim = target, attacker = caster,
      damage = self:GetSpecialValueFor("damage"),
      damage_type = self:GetAbilityDamageType(),
      ability = self
    })

    if target then
      if IsValidEntity(target) then
        AddModifier(target, self, "baldur_5_modifier_fire", {
          duration = self:GetSpecialValueFor("debuff_duration")
        }, true)
      end
    end
  end

-- EFFECTS