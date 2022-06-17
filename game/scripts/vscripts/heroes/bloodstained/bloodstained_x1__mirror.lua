bloodstained_x1__mirror = class({})

-- INIT

	function bloodstained_x1__mirror:CalcStatus(duration, caster, target)
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

	function bloodstained_x1__mirror:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
    end

	function bloodstained_x1__mirror:RemoveBonus(string, target)
		local stringFormat = string.format("%s_modifier_stack", string)
		local mod = target:FindAllModifiersByName(stringFormat)
		for _,modifier in pairs(mod) do
			if modifier:GetAbility() == self then modifier:Destroy() end
		end
	end

	function bloodstained_x1__mirror:OnUpgrade()
		self:SetHidden(false)
	end

	function bloodstained_x1__mirror:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

	function bloodstained_x1__mirror:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		if target:TriggerSpellAbsorb( self ) then return end

		if target:IsIllusion() then
			target:ForceKill(false)
			return
		end

		local seal = caster:FindAbilityByName("bloodstained_u__seal")
		if seal == nil then return end
		if seal:IsTrained() == false then return end

		seal:CreateCopy(target, self)
	end

	function bloodstained_x1__mirror:CastFilterResultTarget( hTarget )
		local caster = self:GetCaster()

		if hTarget:HasModifier("bloodstained_u_modifier_debuff_slow") then
			return	UF_FAIL_CUSTOM
		end

		if caster == hTarget then
			return UF_FAIL_CUSTOM
		end

		local result = UnitFilter(
			hTarget,	-- Target Filter
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
			DOTA_UNIT_TARGET_HERO,	-- Unit Filter
			0,	-- Unit Flag
			caster:GetTeamNumber()	-- Team reference
		)
		
		if result ~= UF_SUCCESS then
			return result
		end

		return UF_SUCCESS
	end

	function bloodstained_x1__mirror:GetCustomCastErrorTarget( hTarget )
		if self:GetCaster() == hTarget then
			return "#dota_hud_error_cant_cast_on_self"
		end
		if hTarget:HasModifier("bloodstained_u_modifier_debuff_slow") then
			return "Can't Cast Ability on this Target"
		end
	end

-- EFFECTS