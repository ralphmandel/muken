bloodstained_1__rage = class({})
LinkLuaModifier("bloodstained_1_modifier_rage", "heroes/death/bloodstained/bloodstained_1_modifier_rage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_1_modifier_rage_status_efx", "heroes/death/bloodstained/bloodstained_1_modifier_rage_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_1_modifier_call", "heroes/death/bloodstained/bloodstained_1_modifier_call", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_1_modifier_call_status_efx", "heroes/death/bloodstained/bloodstained_1_modifier_call_status_efx", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function bloodstained_1__rage:Spawn()
    Timers:CreateTimer(0.2, function()
      if self:IsTrained() == false then
        self:UpgradeAbility(true)
        BaseStats(self:GetCaster()):AddManaExtra(self)
      end
    end)
  end

  function bloodstained_1__rage:OnOwnerSpawned()
    self:SetActivated(true)
  end

  function bloodstained_1__rage:GetAOERadius()
    return self:GetSpecialValueFor("radius")
  end

-- SPELL START

  function bloodstained_1__rage:OnSpellStart()
    local caster = self:GetCaster()
    AddModifier(caster, self, "bloodstained_1_modifier_rage", {duration = self:GetSpecialValueFor("duration")}, true)
    
    local enemies = FindUnitsInRadius(
      caster:GetTeamNumber(), caster:GetOrigin(), nil, self:GetAOERadius(),
      self:GetAbilityTargetTeam(), self:GetAbilityTargetType(),
      self:GetAbilityTargetFlags(), FIND_ANY_ORDER, false
    )

    for _,enemy in pairs(enemies) do
      if enemy:IsHero() or enemy:IsConsideredHero() then
        AddModifier(enemy, self, "bloodstained_1_modifier_call", {
          duration = self:GetSpecialValueFor("call_duration")
        }, true)
      end
    end

    if IsServer() then self:PlayEfxStart() end
  end

-- EFFECTS

  function bloodstained_1__rage:PlayEfxStart()
    local caster = self:GetCaster()
    local radius = self:GetAOERadius()

    local particle_cast = "particles/econ/items/axe/axe_ti9_immortal/axe_ti9_call.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(effect_cast, 2, Vector(radius, radius, radius))
    ParticleManager:SetParticleControlEnt(effect_cast, 1, caster, PATTACH_POINT_FOLLOW, "attach_mouth", Vector(0,0,0), true)
    ParticleManager:ReleaseParticleIndex(effect_cast)

    if IsServer() then
      caster:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
      caster:EmitSound("Bloodstained.fury")
      caster:EmitSound("Bloodstained.rage")
    end
  end