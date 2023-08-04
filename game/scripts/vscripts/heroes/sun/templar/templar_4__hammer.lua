templar_4__hammer = class({})
LinkLuaModifier("templar_4_modifier_hammer", "heroes/sun/templar/templar_4_modifier_hammer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

templar_4__hammer.hits = {}

-- SPELL START

	function templar_4__hammer:OnSpellStart()
    self.hits[self:CreateProj(self:GetCaster(), self:GetCursorTarget())] = self:GetSpecialValueFor("hits")
	end

  function templar_4__hammer:OnProjectileHitHandle(target, location, handle)
    if (not target) or target:IsInvulnerable() or target:TriggerSpellAbsorb(self) then
      self.hits[handle] = nil
      return
    end

		local caster = self:GetCaster()

    self.hits[handle] = self.hits[handle] - 1

    if self.hits[handle] > 0 then
      local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(), location, nil, self:GetCastRange(location, nil),
        self:GetAbilityTargetTeam(), self:GetAbilityTargetType(),
        self:GetAbilityTargetFlags(), 0, false
      )
  
      local new = false
      
      for _,enemy in pairs(enemies) do
        if enemy ~= target and enemy:IsHero() then
          self:CreateProj(target, enemy)
          new = true
          break
        end
      end

      if new == false then self.hits[handle] = nil end
    end

    AddFOWViewer(caster:GetTeamNumber(), target:GetOrigin(), 150, 1, true)
    AddModifier(target, self, "templar_4_modifier_hammer", {}, false)

    ApplyDamage({
      victim = target, attacker = caster,
      damage = caster:GetPhysicalArmorValue(false) * self:GetSpecialValueFor("armor_mult"),
      damage_type = self:GetAbilityDamageType(),
      ability = self
    })
  end

  function templar_4__hammer:CreateProj(source, target)
    local caster = self:GetCaster()
    if IsServer() then caster:EmitSound("Hero_Omniknight.HammerOfPurity.Cast") end

    local projectile = ProjectileManager:CreateTrackingProjectile({
      Target = target, Source = source, Ability = self,
      EffectName = "particles/units/heroes/hero_omniknight/omniknight_hammer_of_purity_projectile.vpcf",
      iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_ATTACK_2,
      iMoveSpeed = self:GetSpecialValueFor("proj_speed"),
      bDodgeable = false, bProvidesVision = true, iVisionRadius = 150
    })

    return projectile
  end

-- EFFECTS