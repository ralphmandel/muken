icebreaker_5__blink = class({})
LinkLuaModifier("icebreaker__modifier_hypo", "heroes/team_moon/icebreaker/icebreaker__modifier_hypo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo_status_efx", "heroes/team_moon/icebreaker/icebreaker__modifier_hypo_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo_dps", "heroes/team_moon/icebreaker/icebreaker__modifier_hypo_dps", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen", "heroes/team_moon/icebreaker/icebreaker__modifier_frozen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen_status_efx", "heroes/team_moon/icebreaker/icebreaker__modifier_frozen_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_instant", "heroes/team_moon/icebreaker/icebreaker__modifier_instant", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_instant_status_efx", "heroes/team_moon/icebreaker/icebreaker__modifier_instant_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_illusion", "heroes/team_moon/icebreaker/icebreaker__modifier_illusion", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_5_modifier_passive", "heroes/team_moon/icebreaker/icebreaker_5_modifier_passive", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function icebreaker_5__blink:Spawn()
    self.kills = 0
    self.turn = 0
    self.break_damage = false

    if self:IsTrained() == false then
      self:UpgradeAbility(true)
    end
  end

  function icebreaker_5__blink:CastFilterResultTarget(hTarget)
		local caster = self:GetCaster()
		if caster == hTarget then return UF_FAIL_CUSTOM end

		if hTarget:GetTeamNumber() ~= caster:GetTeamNumber()
		and hTarget:HasModifier("icebreaker__modifier_frozen") then
			return UF_SUCCESS
		end

		local result = UnitFilter(
			hTarget, self:GetAbilityTargetTeam(),
			self:GetAbilityTargetType(),
			self:GetAbilityTargetFlags(),
			caster:GetTeamNumber()
		)
		
		if result ~= UF_SUCCESS then return result end

		return UF_SUCCESS
	end

	function icebreaker_5__blink:GetCustomCastErrorTarget(hTarget)
		if self:GetCaster() == hTarget then return "#dota_hud_error_cant_cast_on_self" end
	end

  function icebreaker_5__blink:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("cast_range")
  end

  function icebreaker_5__blink:GetBehavior()
		if self:GetSpecialValueFor("special_super_blink") == 1 then return 137472507912 end

    return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
	end

-- SPELL START

  function icebreaker_5__blink:GetIntrinsicModifierName()
    return "icebreaker_5_modifier_passive"
  end

  function icebreaker_5__blink:OnAbilityPhaseInterrupted()
		self.turn = 0
	end

	function icebreaker_5__blink:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local origin = caster:GetOrigin()
		local point = self:GetCursorPosition()
		local distance = CalcDistanceBetweenEntityOBB(caster, target)

		if target:GetTeamNumber() ~= caster:GetTeamNumber() then
			if target:TriggerSpellAbsorb(self) then
				self.turn = 0
				return
			end
		end

		if IsServer() then caster:EmitSound("Hero_QueenOfPain.Blink_out") end

		local direction = target:GetForwardVector() * (-1)
		local blink_point = target:GetAbsOrigin() + direction * 130
    FindClearSpaceForUnit(caster, blink_point, true)
		caster:SetForwardVector(-direction)
		ProjectileManager:ProjectileDodge(caster)

		Timers:CreateTimer(0.1, function()
			self.turn = 0
		end)

		self:PlayEfxBlink(direction, origin, target)

		if target:GetTeamNumber() ~= caster:GetTeamNumber() then
			caster:MoveToTargetToAttack(target)
		end

		if target:HasModifier("icebreaker__modifier_frozen") then
      self:PerformFrostBreak(target)
		end
	end

  function icebreaker_5__blink:PerformFrostBreak(target)
    local caster = self:GetCaster()
    local break_hypo_stack = self:GetSpecialValueFor("special_break_hypo_stack")
    local spread_radius = self:GetSpecialValueFor("special_spread_radius")

    self:PlayEfxBreak(target)
    self:EndCooldown()
  
    if spread_radius > 0 then
      self:PlayEfxSpread(target)
      local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(), target:GetOrigin(), nil, spread_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
        0, 0, false
      )
  
      for _,enemy in pairs(enemies) do
        if IsServer() then enemy:EmitSound("Hero_DrowRanger.Marksmanship.Target") end
        AddModifier(enemy, caster, self, "icebreaker__modifier_hypo", {
          stack = self:GetSpecialValueFor("special_spread_stack")
        }, false)
      end
    end

    target:RemoveModifierByName("icebreaker__modifier_frozen")

    self.break_damage = true

    ApplyDamage({
      victim = target, attacker = caster, ability = self,
      damage = self:GetSpecialValueFor("damage"),
      damage_type = self:GetAbilityDamageType()
    })

    if break_hypo_stack > 0 then
      if target then
        if IsValidEntity(target) then
          if target:IsAlive() then
            AddModifier(target, caster, self, "icebreaker__modifier_hypo", {
              stack = break_hypo_stack
            }, false)
          end
        end
      end
    end
  end

  function icebreaker_5__blink:ReduceShivasCD(target)
		local caster = self:GetCaster()
		local shivas = caster:FindAbilityByName("icebreaker_4__shivas")
		if shivas == nil then return end
		if shivas:IsTrained() == false then return end
		if shivas:IsCooldownReady() then return end
		if target:IsHero() == false then return end
	
		local cooldown = shivas:GetSpecialValueFor("special_cooldown")
		local current_cooldown = shivas:GetCooldownTimeRemaining()
	
		if cooldown > 0 then
			shivas:EndCooldown()
			shivas:StartCooldown(current_cooldown - cooldown)
		end
	end

-- EFFECTS

  function icebreaker_5__blink:PlayEfxBlink(direction, origin, target)
    local caster = self:GetCaster()
    local particle_cast_a = "particles/econ/events/winter_major_2017/blink_dagger_start_wm07.vpcf" 
    local particle_cast_b = "particles/econ/events/winter_major_2017/blink_dagger_end_wm07.vpcf"

    local effect_cast_a = ParticleManager:CreateParticle(particle_cast_a, PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(effect_cast_a, 0, origin)
    ParticleManager:SetParticleControlForward(effect_cast_a, 0, direction:Normalized())
    ParticleManager:SetParticleControl(effect_cast_a, 1, origin + direction)
    ParticleManager:ReleaseParticleIndex(effect_cast_a)

    local effect_cast_b = ParticleManager:CreateParticle(particle_cast_b, PATTACH_ABSORIGIN, caster)
    ParticleManager:SetParticleControl(effect_cast_b, 0, caster:GetOrigin())
    ParticleManager:SetParticleControlForward(effect_cast_b, 0, direction:Normalized())
    ParticleManager:ReleaseParticleIndex(effect_cast_b)

    if IsServer() then caster:EmitSound("Hero_Antimage.Blink_in.Persona") end
  end

  function icebreaker_5__blink:PlayEfxBreak(target)
		local caster = self:GetCaster()
		local particle_cast = "particles/units/heroes/hero_phantom_assassin_persona/pa_persona_crit_impact.vpcf"
		local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(effect_cast, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(effect_cast, 1, target:GetAbsOrigin())
		ParticleManager:SetParticleControlTransformForward(effect_cast, 1, target:GetOrigin(), target:GetForwardVector() * (-1))
		ParticleManager:ReleaseParticleIndex(effect_cast)

		if IsServer() then target:EmitSound("Hero_Ancient_Apparition.IceBlastRelease.Cast") end
		if IsServer() then target:EmitSound("Hero_Icebreaker.Break") end
	end

  function icebreaker_5__blink:PlayEfxSpread(target)
    local particle = "particles/econ/items/ancient_apparition/aa_blast_ti_5/ancient_apparition_ice_blast_explode_ti5.vpcf"
    local effect_cast = ParticleManager:CreateParticle(particle, PATTACH_WORLDORIGIN, nil)
    ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
  end