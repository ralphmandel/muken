genuine_2__fallen = class({})
LinkLuaModifier("genuine_2_modifier_dispel", "heroes/team_moon/genuine/genuine_2_modifier_dispel", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine__modifier_fear", "heroes/team_moon/genuine/genuine__modifier_fear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine__modifier_fear_status_efx", "heroes/team_moon/genuine/genuine__modifier_fear_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

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
		local mana_steal = self:GetSpecialValueFor("mana_steal")
		local dispel_duration = self:GetSpecialValueFor("special_dispel_duration")

		hTarget:AddNewModifier(caster, self, "genuine__modifier_fear", {
			duration = CalcStatus(self:GetSpecialValueFor("fear_duration"), caster, hTarget)
		})

		if mana_steal > hTarget:GetMana() then mana_steal = hTarget:GetMana() end
		
		if mana_steal > 0 then
      ReduceMana(hTarget, self, mana_steal)
			caster:GiveMana(mana_steal)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, hTarget, mana_steal, caster)
			SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, caster, mana_steal, caster)
		end

		if dispel_duration > 0 then
			hTarget:AddNewModifier(caster, self, "genuine_2_modifier_dispel", {duration = dispel_duration})
		end

		self:PlayEfxHit(hTarget)
	end

-- EFFECTS

	function genuine_2__fallen:PlayEfxHit(target)
		local particle_cast = "particles/genuine/genuine_fallen_hit.vpcf"
		local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:ReleaseParticleIndex(effect_cast)
	end