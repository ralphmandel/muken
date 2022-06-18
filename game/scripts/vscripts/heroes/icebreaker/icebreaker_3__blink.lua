icebreaker_3__blink = class({})

-- INIT

	function icebreaker_3__blink:CalcStatus(duration, caster, target)
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
					local value = base_stats_target.stat_total["RES"] * 0.4
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

	function icebreaker_3__blink:AddBonus(string, target, const, percent, time)
		local base_stats = target:FindAbilityByName("base_stats")
		if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
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
		if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[3][upgrade] end
	end

	function icebreaker_3__blink:OnUpgrade()
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_riki" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then base_hero.ranks[3][0] = true end
		
		local charges = 1

	    -- UP 3.12
        if self:GetRank(12) then
            charges = charges * 2
        end

		-- UP 3.13
        if self:GetRank(13) then
            charges = charges * 3
        end

		-- UP 3.41
        if self:GetRank(41) then
            charges = charges * 5
        end

		self:SetCurrentAbilityCharges(charges)
	end

	function icebreaker_3__blink:Spawn()
		self:SetCurrentAbilityCharges(0)
		self.blink_lifesteal = false
	end

-- SPELL START

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

		if IsServer() then caster:EmitSound("Hero_QueenOfPain.Blink_out") end

		local blinkDistance = 100
		local blinkDirection = (caster:GetOrigin() - target:GetOrigin()):Normalized() * blinkDistance
		local blinkPosition = target:GetOrigin() + blinkDirection

		caster:SetOrigin( blinkPosition )
		FindClearSpaceForUnit(caster, blinkPosition, true)
		ProjectileManager:ProjectileDodge(caster)
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
		local behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
        if self:GetCurrentAbilityCharges() == 0 then return behavior end

		if self:GetCurrentAbilityCharges() % 3 == 0 then
			behavior = DOTA_ABILITY_BEHAVIOR_UNIT_TARGET
		end

        if self:GetCurrentAbilityCharges() % 5 == 0 then
			behavior = behavior + DOTA_ABILITY_BEHAVIOR_AOE
		end

        return behavior
    end

	function icebreaker_3__blink:GetAOERadius()
		if self:GetCurrentAbilityCharges() == 0 then return 0 end
		if self:GetCurrentAbilityCharges() == 1 then return 0 end
		if self:GetCurrentAbilityCharges() % 5 == 0 then return 250 end
		return 0
	end

	function icebreaker_3__blink:GetCastRange(vLocation, hTarget)
        local cast_range = self:GetSpecialValueFor("cast_range")
        if self:GetCurrentAbilityCharges() == 0 then return cast_range end
        if self:GetCurrentAbilityCharges() == 1 then return cast_range end
        if self:GetCurrentAbilityCharges() % 3 == 0 then return cast_range + 250 end
        return cast_range
    end

	function icebreaker_3__blink:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
		if self:GetCurrentAbilityCharges() % 2 == 0 then manacost = manacost - 15 end
        return manacost * level
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