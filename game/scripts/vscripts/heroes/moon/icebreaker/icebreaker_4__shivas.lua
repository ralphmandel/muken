icebreaker_4__shivas = class({})
LinkLuaModifier("icebreaker__modifier_hypo", "heroes/moon/icebreaker/icebreaker__modifier_hypo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo_status_efx", "heroes/moon/icebreaker/icebreaker__modifier_hypo_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen", "heroes/moon/icebreaker/icebreaker__modifier_frozen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen_status_efx", "heroes/moon/icebreaker/icebreaker__modifier_frozen_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_instant", "heroes/moon/icebreaker/icebreaker__modifier_instant", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_instant_status_efx", "heroes/moon/icebreaker/icebreaker__modifier_instant_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_illusion", "heroes/moon/icebreaker/icebreaker__modifier_illusion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_bat_increased", "_modifiers/_modifier_bat_increased", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_fear", "_modifiers/_modifier_fear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_fear_status_efx", "_modifiers/_modifier_fear_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_4_modifier_shivas", "heroes/moon/icebreaker/icebreaker_4_modifier_shivas", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function icebreaker_4__shivas:OnSpellStart()
    local caster = self:GetCaster()
    local heal = self:GetSpecialValueFor("special_heal")
    local blast_radius = self:GetSpecialValueFor("blast_radius")
    local blast_speed = self:GetSpecialValueFor("blast_speed")
    local blast_duration = blast_radius / blast_speed
    local current_loc = caster:GetAbsOrigin()
    
    self:PlayEfxActive(blast_radius, blast_duration, blast_speed)

    AddModifier(caster, caster, self, "_modifier_percent_movespeed_debuff", {
      duration =  blast_duration, percent = self:GetSpecialValueFor("slow")
    }, false)

    local targets_hit = {}
    local current_radius = 0
    local tick_interval = 0.1

    Timers:CreateTimer(tick_interval, function()
      AddFOWViewer(caster:GetTeamNumber(), current_loc, current_radius, 0.1, false)
      current_radius = current_radius + blast_speed * tick_interval
      current_loc = caster:GetAbsOrigin()

      local nearby_units = FindUnitsInRadius(
        caster:GetTeamNumber(), current_loc, nil, current_radius, DOTA_UNIT_TARGET_TEAM_BOTH,
        self:GetAbilityTargetType(), self:GetAbilityTargetFlags(), 0, false
      )

      for _,unit in pairs(nearby_units) do
        local unit_has_been_hit = false
        for _,unit_hit in pairs(targets_hit) do
          if unit == unit_hit then unit_has_been_hit = true end
        end

        if not unit_has_been_hit then
          targets_hit[#targets_hit + 1] = unit
          if unit:GetTeamNumber() == caster:GetTeamNumber() then
            if heal > 0 and caster ~= unit then
              unit:Heal(heal * BaseStats(caster):GetHealPower(), self)
            end
          else
            if unit:IsIllusion() then
              unit:Kill(self, caster)
            else
              AddModifier(unit, caster, self, "icebreaker__modifier_hypo", {
                stack = self:GetSpecialValueFor("hypo_stack")
              }, false)

              if unit:HasModifier("icebreaker__modifier_frozen") == false then
                RemoveAllModifiersByNameAndAbility(unit, "_modifier_fear", self)
                AddModifier(unit, caster, self, "_modifier_fear", {
                  duration = self:GetSpecialValueFor("special_fear_duration")
                }, true)
              end
            end
          end
          self:PlayEfxHit(unit)
        end
      end

      if current_radius < blast_radius then
        return tick_interval
      end
    end)
  end

-- EFFECTS

  function icebreaker_4__shivas:PlayEfxActive(blast_radius, blast_duration, blast_speed)
    local caster = self:GetCaster()
    local blast_pfx = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_active.vpcf", PATTACH_ABSORIGIN_FOLLOW, caster)
    ParticleManager:SetParticleControl(blast_pfx, 0, caster:GetAbsOrigin())
    ParticleManager:SetParticleControl(blast_pfx, 1, Vector(blast_radius, blast_duration * 1.33, blast_speed))
    ParticleManager:ReleaseParticleIndex(blast_pfx)

    if IsServer() then caster:EmitSound("DOTA_Item.ShivasGuard.Activate") end
  end

  function icebreaker_4__shivas:PlayEfxHit(enemy)
    local caster = self:GetCaster()
    local hit_pfx = ParticleManager:CreateParticle("particles/items2_fx/shivas_guard_impact.vpcf", PATTACH_ABSORIGIN_FOLLOW, enemy)
    ParticleManager:SetParticleControl(hit_pfx, 0, enemy:GetAbsOrigin())
    ParticleManager:SetParticleControl(hit_pfx, 1, enemy:GetAbsOrigin())
    ParticleManager:ReleaseParticleIndex(hit_pfx)
  end