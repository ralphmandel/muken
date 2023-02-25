icebreaker_u__blink = class({})
LinkLuaModifier("icebreaker_u_modifier_passive", "heroes/icebreaker/icebreaker_u_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

	function icebreaker_u__blink:Spawn()
		self.turn = 0
	end

-- SPELL START

	function icebreaker_u__blink:GetIntrinsicModifierName()
		return "icebreaker_u_modifier_passive"
	end

	function icebreaker_u__blink:OnAbilityPhaseInterrupted()
		self.turn = 0
	end

	function icebreaker_u__blink:OnSpellStart()
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
		caster:SetAbsOrigin(blink_point)
		caster:SetForwardVector(-direction)
		FindClearSpaceForUnit(caster, blink_point, true)
		ProjectileManager:ProjectileDodge(caster)

		Timers:CreateTimer(0.1, function()
			self.turn = 0
		end)

		self:PlayEfxBlink(direction, origin, target)

		if target:GetTeamNumber() ~= caster:GetTeamNumber() then
			caster:MoveToTargetToAttack(target)
		end

		if target:HasModifier("icebreaker__modifier_frozen") then
			self:PerformBreak(target)
		end
	end

	function icebreaker_u__blink:PerformBreak(target)
		local caster = self:GetCaster()
		target:RemoveModifierByName("icebreaker__modifier_frozen")

		self:PlayEfxBreak(target)
		self:EndCooldown()
		self:ReduceShivasCD(target)

		ApplyDamage({
			victim = target, attacker = caster, ability = self,
			damage = self:GetSpecialValueFor("damage"),
			damage_type = self:GetAbilityDamageType()
		})
	end

	function icebreaker_u__blink:ReduceShivasCD(target)
		local caster = self:GetCaster()
		local shivas = caster:FindAbilityByName("icebreaker_5__shivas")
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

	function icebreaker_u__blink:CastFilterResultTarget(hTarget)
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

	function icebreaker_u__blink:GetCustomCastErrorTarget(hTarget)
		if self:GetCaster() == hTarget then return "#dota_hud_error_cant_cast_on_self" end
	end

	function icebreaker_u__blink:GetBehavior()
		if self:GetSpecialValueFor("special_no_roots") == 1 then
			return DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
		end

		return DOTA_ABILITY_BEHAVIOR_NOT_LEARNABLE + DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_DONT_RESUME_ATTACK
	end

-- EFFECTS

	function icebreaker_u__blink:PlayEfxBlink(direction, origin, target)
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

	function icebreaker_u__blink:PlayEfxBreak(target)
		local caster = self:GetCaster()
		local particle_cast = "particles/units/heroes/hero_phantom_assassin_persona/pa_persona_crit_impact.vpcf"
		local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, target)
		ParticleManager:SetParticleControlEnt(effect_cast, 0, target, PATTACH_POINT_FOLLOW, "attach_hitloc", target:GetAbsOrigin(), true)
		ParticleManager:SetParticleControl(effect_cast, 1, target:GetAbsOrigin())
		ParticleManager:SetParticleControlOrientation(effect_cast, 1, caster:GetForwardVector() * (-1), caster:GetRightVector(), caster:GetUpVector())
		ParticleManager:ReleaseParticleIndex(effect_cast)

		if IsServer() then target:EmitSound("Hero_Ancient_Apparition.IceBlastRelease.Cast") end
		if IsServer() then target:EmitSound("Hero_Icebreaker.Break") end
	end