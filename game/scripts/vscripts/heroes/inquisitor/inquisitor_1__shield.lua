inquisitor_1__shield = class({})
LinkLuaModifier( "inquisitor_1_modifier_shield", "heroes/inquisitor/inquisitor_1_modifier_shield", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

	function inquisitor_1__shield:CalcStatus(duration, caster, target)
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

	function inquisitor_1__shield:AddBonus(string, target, const, percent, time)
		local att = target:FindAbilityByName(string)
		if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
	end

	function inquisitor_1__shield:RemoveBonus(string, target)
		local stringFormat = string.format("%s_modifier_stack", string)
		local mod = target:FindAllModifiersByName(stringFormat)
		for _,modifier in pairs(mod) do
			if modifier:GetAbility() == self then modifier:Destroy() end
		end
	end

	function inquisitor_1__shield:GetRank(upgrade)
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		local att = caster:FindAbilityByName("inquisitor__attributes")
		if not att then return end
		if not att:IsTrained() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

		return att.talents[1][upgrade]
	end

	function inquisitor_1__shield:OnUpgrade()
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

		local att = caster:FindAbilityByName("inquisitor__attributes")
		if att then
			if att:IsTrained() then
				att.talents[1][0] = true
			end
		end
		
		if self:GetLevel() == 1 then caster:FindAbilityByName("_2_DEX"):CheckLevelUp(true) end
		if self:GetLevel() == 1 then caster:FindAbilityByName("_2_DEF"):CheckLevelUp(true) end
		if self:GetLevel() == 1 then caster:FindAbilityByName("_2_RES"):CheckLevelUp(true) end
		if self:GetLevel() == 1 then caster:FindAbilityByName("_2_REC"):CheckLevelUp(true) end
		if self:GetLevel() == 1 then caster:FindAbilityByName("_2_MND"):CheckLevelUp(true) end
		if self:GetLevel() == 1 then caster:FindAbilityByName("_2_LCK"):CheckLevelUp(true) end

		local charges = 1

		-- UP 1.2
		if self:GetRank(2) then
			charges = charges * 2
		end

		self:SetCurrentAbilityCharges(charges)
	end

	function inquisitor_1__shield:Spawn()
		self:SetCurrentAbilityCharges(0)
		self.autocast = false
	end

-- SPELL START

	function inquisitor_1__shield:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local duration = self:GetSpecialValueFor("duration")

		target:AddNewModifier(caster, self, "inquisitor_1_modifier_shield", {duration = self:CalcStatus(duration, caster, target)})

		self.autocast = false
	end

	function inquisitor_1__shield:EnableAutoCast()
		self.autocast = true
	end

	function inquisitor_1__shield:CastFilterResultTarget( hTarget )
		local caster = self:GetCaster()

		if hTarget:IsBuilding() == true then
			if self:GetCurrentAbilityCharges() % 2 ~= 0 then
				return UF_FAIL_BUILDING
			end
		end

		local result = UnitFilter(
			hTarget,	-- Target Filter
			DOTA_UNIT_TARGET_TEAM_FRIENDLY,	-- Team Filter
			DOTA_UNIT_TARGET_BUILDING + DOTA_UNIT_TARGET_HERO,	-- Unit Filter
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- Unit Flag
			caster:GetTeamNumber()	-- Team reference
		)
		
		if result ~= UF_SUCCESS then
			return result
		end

		return UF_SUCCESS
	end

	function inquisitor_1__shield:GetAbilityTargetType()
		if self:GetCurrentAbilityCharges() == 0 then return 1 end
		if self:GetCurrentAbilityCharges() == 1 then return 1 end
		if self:GetCurrentAbilityCharges() % 2 == 0 then return 5 end
	end

	function inquisitor_1__shield:GetCastRange()
		if self:GetCurrentAbilityCharges() == 0 then return 750 end
		if self:GetCurrentAbilityCharges() == 1 then return 750 end
		if self:GetCurrentAbilityCharges() % 2 == 0 then return 1500 end
	end

-- EFFECTS