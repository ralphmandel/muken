icebreaker_3__blink = class({})

-- INIT

	function icebreaker_3__blink:CalcStatus(duration, caster, target)
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

	function icebreaker_3__blink:AddBonus(string, target, const, percent, time)
		local att = target:FindAbilityByName(string)
		if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
	end

	function icebreaker_3__blink:RemoveBonus(string, target)
		local stringFormat = string.format("%s_modifier_stack", string)
		local mod = target:FindAllModifiersByName(stringFormat)
		for _,modifier in pairs(mod) do
			if modifier:GetAbility() == self then modifier:Destroy() end
		end
	end

	function icebreaker_3__blink:GetRank(upgrade)
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		local att = caster:FindAbilityByName("icebreaker__attributes")
		if not att then return end
		if not att:IsTrained() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

		return att.talents[3][upgrade]
	end

	function icebreaker_3__blink:OnUpgrade()
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

		local att = caster:FindAbilityByName("icebreaker__attributes")
		if att then
			if att:IsTrained() then
				att.talents[3][0] = true
			end
		end
		
		if self:GetLevel() == 1 then caster:FindAbilityByName("_2_DEX"):CheckLevelUp(true) end
		if self:GetLevel() == 1 then caster:FindAbilityByName("_2_DEF"):CheckLevelUp(true) end
		if self:GetLevel() == 1 then caster:FindAbilityByName("_2_RES"):CheckLevelUp(true) end
		if self:GetLevel() == 1 then caster:FindAbilityByName("_2_REC"):CheckLevelUp(true) end
		if self:GetLevel() == 1 then caster:FindAbilityByName("_2_MND"):CheckLevelUp(true) end
		if self:GetLevel() == 1 then caster:FindAbilityByName("_2_LCK"):CheckLevelUp(true) end
		
		local charges = 1

	    -- UP 3.4
        if self:GetRank(4) then
            charges = charges * 2           
        end

		self:SetCurrentAbilityCharges(charges)
	end

	function icebreaker_3__blink:Spawn()
		self:SetCurrentAbilityCharges(0)
	end

-- SPELL START

	function icebreaker_3__blink:GetAOERadius()
		if self:GetCurrentAbilityCharges() == 0 then return 0 end
		if self:GetCurrentAbilityCharges() == 1 then return 0 end
		if self:GetCurrentAbilityCharges() % 2 == 0 then return 300 end
		return 0
	end

	function icebreaker_3__blink:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local origin = caster:GetOrigin()
		local point = self:GetCursorPosition()
		local direction = (point - origin)

		if target:GetTeamNumber()~=caster:GetTeamNumber() then
			if target:TriggerSpellAbsorb(self) then
				return
			end
		end
		
		local ability_slow = caster:FindAbilityByName("icebreaker_0__slow")
		if ability_slow then
			if ability_slow:IsTrained()
			and target:GetTeamNumber() == caster:GetTeamNumber() then
				-- UP 3.3
				if self:GetRank(3) then
					local freeze_duration = ability_slow:GetSpecialValueFor("freeze_duration")
					target:AddNewModifier(caster, ability_slow, "icebreaker_0_modifier_freeze", {
						duration = freeze_duration
					})
				end
			end
		end

		if IsServer() then caster:EmitSound("Hero_QueenOfPain.Blink_out") end

		local blinkDistance = 100
		local blinkDirection = (caster:GetOrigin() - target:GetOrigin()):Normalized() * blinkDistance
		local blinkPosition = target:GetOrigin() + blinkDirection

		caster:SetOrigin( blinkPosition )
		FindClearSpaceForUnit(caster, blinkPosition, true)
		caster:MoveToTargetToAttack(target)

		self:PlayEffects(direction, origin, target)
	end

	function icebreaker_3__blink:CastFilterResultTarget( hTarget )
		local caster = self:GetCaster()

		if caster == hTarget then
			return UF_FAIL_CUSTOM
		end

		if caster:HasModifier("icebreaker_x1_modifier_skin") then
			if caster:GetRangeToUnit(hTarget) > self:GetCastRange(caster:GetOrigin(), hTarget) then
				return UF_FAIL_CUSTOM
			end
		end

		if hTarget:GetTeamNumber() ~= caster:GetTeamNumber()
		and hTarget:HasModifier("icebreaker_0_modifier_freeze") then
			return UF_SUCCESS
		end

		local result = UnitFilter(
			hTarget,	-- Target Filter
			DOTA_UNIT_TARGET_TEAM_BOTH,	-- Team Filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
			0,	-- Unit Flag
			caster:GetTeamNumber()	-- Team reference
		)
		
		if result ~= UF_SUCCESS then
			return result
		end

		return UF_SUCCESS
	end

	function icebreaker_3__blink:GetCustomCastErrorTarget( hTarget )
		if self:GetCaster() == hTarget then
			return "#dota_hud_error_cant_cast_on_self"
		end

		return "No Range"
	end

    function icebreaker_3__blink:GetBehavior()
        if self:GetCurrentAbilityCharges() == 0 then return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES end
        if self:GetCurrentAbilityCharges() == 1 then return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES + DOTA_ABILITY_BEHAVIOR_AOE end
        return DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
    end

-- EFFECTS

	function icebreaker_3__blink:PlayEffects( direction, origin, target )
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