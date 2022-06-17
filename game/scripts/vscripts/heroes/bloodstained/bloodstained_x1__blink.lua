bloodstained_x1__blink = class({})

-- INIT

	function bloodstained_x1__blink:CalcStatus(duration, caster, target)
		local time = duration
		local base_stats_caster = nil
		local base_stats_target = nil

		if caster ~= nil then
			base_stats_caster = caster:FindAbilityByName("base_stats")
		end

		if target ~= nil then
			base_stats_target = target:FindAbilityByName("base_stats")
		end

		if caster == nil then
			if target ~= nil then
				if base_stats_target then
					local value = base_stats_target.stat_total["RES"] * 0.7
					local calc = (value * 6) / (1 +  (value * 0.06))
					time = time * (1 - (calc * 0.01))
				end
			end
		else
			if target == nil then
				if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
			else
				if caster:GetTeamNumber() == target:GetTeamNumber() then
					if base_stats_caster then time = duration * (1 + base_stats_caster:GetBuffAmp()) end
				else
					if base_stats_caster and base_stats_target then
						local value = (base_stats_caster.stat_total["INT"] - base_stats_target.stat_total["RES"]) * 0.7
						if value > 0 then
							local calc = (value * 6) / (1 +  (value * 0.06))
							time = time * (1 + (calc * 0.01))
						else
							value = -1 * value
							local calc = (value * 6) / (1 +  (value * 0.06))
							time = time * (1 - (calc * 0.01))
						end
					end
				end
			end
		end

		if time < 0 then time = 0 end
		return time
	end

	function bloodstained_x1__blink:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

	function bloodstained_x1__blink:RemoveBonus(string, target)
		local stringFormat = string.format("%s_modifier_stack", string)
		local mod = target:FindAllModifiersByName(stringFormat)
		for _,modifier in pairs(mod) do
			if modifier:GetAbility() == self then modifier:Destroy() end
		end
	end

	function bloodstained_x1__blink:OnUpgrade()
		self:SetHidden(false)
	end

	function bloodstained_x1__blink:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

	function bloodstained_x1__blink:OnSpellStart()
		local caster = self:GetCaster()
		local origin = caster:GetOrigin()
		local target = self:GetCursorTarget()
		target:RemoveModifierByName("bloodstained_u_modifier_copy")

		local point = target:GetOrigin()
		local direction = (point - origin)

		local blinkDistance = 1
		local blinkDirection = (caster:GetOrigin() - target:GetOrigin()):Normalized() * blinkDistance
		local blinkPosition = target:GetOrigin() + blinkDirection

		if IsServer() then caster:EmitSound("Hero_Antimage.Blink_in.Persona") end

		caster:SetOrigin(blinkPosition)
		self:PlayEfxBlink(direction, origin)
		FindClearSpaceForUnit(caster, blinkPosition, true)
		ProjectileManager:ProjectileDodge(caster)

		if IsServer() then caster:EmitSound("Hero_Antimage.Blink_in.Persona") end
	end

	function bloodstained_x1__blink:OnHeroDiedNearby(unit, attacker, keys)
		local caster = self:GetCaster()
		local distance = self:GetSpecialValueFor("distance")

		if unit == nil then return end
		if not unit:IsHero() then return end
		if unit:GetTeamNumber() == caster:GetTeamNumber() then return end
		if CalcDistanceBetweenEntityOBB(unit, caster) > distance then return end

		self:EndCooldown()
	end

	function bloodstained_x1__blink:CastFilterResultTarget(hTarget)
		local caster = self:GetCaster()

		if hTarget:HasModifier("bloodstained_u_modifier_copy") 
		and hTarget:GetTeamNumber() == caster:GetTeamNumber() then
			return UF_SUCCESS
		end

		return UF_FAIL_CUSTOM
	end

	function bloodstained_x1__blink:GetCustomCastErrorTarget(hTarget)
		return "Is Not a Blood Illusion"
	end

-- EFFECTS

	function bloodstained_x1__blink:PlayEfxBlink(direction, origin)
		local caster = self:GetCaster()
		local particle_cast_a = "particles/econ/events/ti6/blink_dagger_start_ti6.vpcf"
		local particle_cast_b = "particles/econ/events/ti6/blink_dagger_end_ti6.vpcf" 

		local effect_cast_a = ParticleManager:CreateParticle(particle_cast_a, PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(effect_cast_a, 0, origin)
		ParticleManager:SetParticleControlForward(effect_cast_a, 0, direction:Normalized())
		ParticleManager:SetParticleControl(effect_cast_a, 1, origin + direction)
		ParticleManager:ReleaseParticleIndex(effect_cast_a)
		
		local effect_cast_b = ParticleManager:CreateParticle(particle_cast_b, PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(effect_cast_b, 0, caster:GetOrigin())
		ParticleManager:SetParticleControlForward(effect_cast_b, 0, direction:Normalized())
		ParticleManager:ReleaseParticleIndex(effect_cast_b)
	end