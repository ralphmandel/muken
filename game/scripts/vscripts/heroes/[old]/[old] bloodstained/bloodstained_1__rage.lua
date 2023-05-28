bloodstained_1__rage = class({})
LinkLuaModifier("bloodstained_1_modifier_rage", "heroes/team_death/bloodstained/bloodstained_1_modifier_rage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_1_modifier_rage_status_efx", "heroes/team_death/bloodstained/bloodstained_1_modifier_rage_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_1_modifier_call", "heroes/team_death/bloodstained/bloodstained_1_modifier_call", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_1_modifier_call_status_efx", "heroes/team_death/bloodstained/bloodstained_1_modifier_call_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_1_modifier_passive_status_efx", "heroes/team_death/bloodstained/bloodstained_1_modifier_passive_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function bloodstained_1__rage:Spawn()
    if self:IsTrained() == false then self:UpgradeAbility(true) end
  end

-- SPELL START

  function bloodstained_1__rage:GetIntrinsicModifierName()
    return "bloodstained_1_modifier_passive_status_efx"
  end

  function bloodstained_1__rage:OnOwnerSpawned()
    self:SetActivated(true)
  end

  function bloodstained_1__rage:OnSpellStart()
    local caster = self:GetCaster()

    caster:AddNewModifier(caster, self, "bloodstained_1_modifier_rage", {
      duration = CalcStatus(self:GetSpecialValueFor("duration"), caster, caster)
    })

    self:PerformCall()
    
    if IsServer() then
      caster:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
      caster:EmitSound("Bloodstained.fury")
      caster:EmitSound("Bloodstained.rage")
    end
  end

  function bloodstained_1__rage:PerformCall()
    local caster = self:GetCaster()
    local call_duration = self:GetSpecialValueFor("special_call_duration")
    if call_duration == 0 then return end

    self:PlayEfxCall(self:GetAOERadius())

    local units = FindUnitsInRadius(
      caster:GetTeamNumber(), caster:GetOrigin(), nil, self:GetAOERadius(),
      DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
      DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false
    )

    for _,unit in pairs(units) do
      unit:AddNewModifier(caster, self, "bloodstained_1_modifier_call", {
        duration = CalcStatus(call_duration, caster, unit)
      })
    end
  end

  function bloodstained_1__rage:GetAOERadius()
    return self:GetSpecialValueFor("special_call_radius")
  end

-- EFFECTS

  function bloodstained_1__rage:PlayEfxCall(radius)
    local caster = self:GetCaster()
    local particle_cast = "particles/econ/items/axe/axe_ti9_immortal/axe_ti9_call.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(effect_cast, 2, Vector(radius, radius, radius))
    ParticleManager:SetParticleControlEnt(effect_cast, 1, caster, PATTACH_POINT_FOLLOW, "attach_mouth", Vector(0,0,0), true)
    ParticleManager:ReleaseParticleIndex(effect_cast)
  end

-- OLD

    -- function bloodstained_1__rage:OnSpellStart()
    --     local caster = self:GetCaster()
    --     --caster:StartGesture(1591)
        
    --     caster:StartGesture(1783)
    --     caster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_NONE)
    --     caster:AttackNoEarlierThan(0.7, 99)

    --     self:EndCooldown()
    --     self:SetActivated(false)

    --     Timers:CreateTimer(0.7, function()
    --         caster:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
    --     end)

    --     Timers:CreateTimer(0.35, function()
    --         if caster:IsAlive() then
    --             self:ApllyBuff()
    --         else
    --             self:StartCooldown(self:GetEffectiveCooldown(self:GetLevel()))
    --             self:SetActivated(true)
    --         end
    --     end)
    -- end