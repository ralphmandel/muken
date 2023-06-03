genuine_2__fallen = class({})
LinkLuaModifier("genuine_2_modifier_fallen", "heroes/team_moon/genuine/genuine_2_modifier_fallen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_fear", "_modifiers/_modifier_fear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_fear_status_efx", "_modifiers/_modifier_fear_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "_modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_truesight", "_modifiers/_modifier_truesight", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_break", "_modifiers/_modifier_break", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function genuine_2__fallen:GetAbilityTargetTeam()
    if self:GetSpecialValueFor("special_heal") > 0 or self:GetSpecialValueFor("special_purge_ally") == 1 then
      return DOTA_UNIT_TARGET_TEAM_BOTH
    end

    return DOTA_UNIT_TARGET_TEAM_ENEMY
  end

-- SPELL START

	function genuine_2__fallen:OnSpellStart()
		local caster = self:GetCaster()
		local point = self:GetCursorPosition()
		local projectile_name = "particles/econ/items/drow/drow_ti6_gold/drow_ti6_silence_gold_wave.vpcf"
		local direction = point - caster:GetOrigin()
		direction.z = 0
		direction = direction:Normalized()

    if self:GetSpecialValueFor("special_wide") == 1 then
			projectile_name = "particles/econ/items/drow/drow_ti6_gold/drow_ti6_silence_gold_wave_wide.vpcf"
		end

		ProjectileManager:CreateLinearProjectile({
			Source = caster,
			Ability = self,
			vSpawnOrigin = caster:GetAbsOrigin(),
			
			bDeleteOnHit = false,
			
			iUnitTargetTeam = self:GetAbilityTargetTeam(),
			iUnitTargetFlags = self:GetAbilityTargetFlags(),
			iUnitTargetType = self:GetAbilityTargetType(),
			
			EffectName = projectile_name,
			fDistance = self:GetSpecialValueFor("distance"),
			fStartRadius = self:GetSpecialValueFor("radius"),
			fEndRadius = self:GetSpecialValueFor("radius"),
			vVelocity = direction * self:GetSpecialValueFor("speed"),

			bProvidesVision = true,
			iVisionRadius = self:GetSpecialValueFor("radius"),
			iVisionTeamNumber = caster:GetTeamNumber()
		})

		if IsServer() then caster:EmitSound("Hero_DrowRanger.Silence") end
	end

	function genuine_2__fallen:OnProjectileHit(hTarget, vLocation)
		if not hTarget then return end
		local caster = self:GetCaster()
    if hTarget == caster then return end

    if hTarget:GetTeamNumber() == caster:GetTeamNumber() then
      local purge_ally = self:GetSpecialValueFor("special_purge_ally")
      local heal = hTarget:GetMaxHealth() * self:GetSpecialValueFor("special_heal") * 0.01

      if purge_ally == 1 then hTarget:Purge(false, true, false, true, false) end
      if heal > 0 then hTarget:Heal(heal, self) end
      return
    end

    if self:GetSpecialValueFor("special_purge_enemy") == 1 then
      hTarget:Purge(true, false, false, false, false)
    end

    AddModifier(hTarget, caster, self, "genuine_2_modifier_fallen", {
      duration = self:GetSpecialValueFor("fear_duration")
    }, true)		
	end

-- EFFECTS

