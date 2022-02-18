bloodstained_x1__mirror = class({})

-- INIT

	function bloodstained_x1__mirror:CalcStatus(duration, caster, target)
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

	function bloodstained_x1__mirror:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
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