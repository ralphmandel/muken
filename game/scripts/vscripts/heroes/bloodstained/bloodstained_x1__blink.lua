bloodstained_x1__blink = class({})

-- INIT

	function bloodstained_x1__blink:CalcStatus(duration, caster, target)
		local time = duration
		if caster == nil then return time end
		local caster_int = caster:FindModifierByName("_1_INT_modifier")
		local caster_mnd = caster:FindModifierByName("_2_MND_modifier")

		if target == nil then
			if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
		else
			if caster:GetTeamNumber() == target:GetTeamNumber() then
				if caster_mnd then time = duration * (1 + caster_mnd:GetBuffAmp()) end
			else
				local target_res = target:FindModifierByName("_2_RES_modifier")
				if caster_int then time = duration * (1 + caster_int:GetDebuffTime()) end
				if target_res then time = time * (1 - target_res:GetStatus()) end
			end
		end

		if time < 0 then time = 0 end
		return time
	end

	function bloodstained_x1__blink:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
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