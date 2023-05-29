genuine_2__fallen = class({})
LinkLuaModifier("_modifier_fear", "_modifiers/_modifier_fear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_fear_status_efx", "_modifiers/_modifier_fear_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function genuine_2__fallen:OnSpellStart()
		local caster = self:GetCaster()
		local point = self:GetCursorPosition()
		local projectile_name = "particles/econ/items/drow/drow_ti6_gold/drow_ti6_silence_gold_wave.vpcf"
		local direction = point - caster:GetOrigin()
		direction.z = 0
		direction = direction:Normalized()

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

    hTarget:Purge(true, false, false, false, false)

    AddModifier(hTarget, caster, self, "_modifier_fear", {
      duration = self:GetSpecialValueFor("fear_duration"), special = 1
    }, true)
		
		self:PlayEfxHit(hTarget)
	end

-- EFFECTS

	function genuine_2__fallen:PlayEfxHit(target)
		local particle_cast = "particles/genuine/genuine_fallen_hit.vpcf"
		local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:ReleaseParticleIndex(effect_cast)
	end