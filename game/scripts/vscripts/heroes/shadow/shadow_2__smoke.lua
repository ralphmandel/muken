shadow_2__smoke = class({})
LinkLuaModifier("shadow_0_modifier_poison", "heroes/shadow/shadow_0_modifier_poison", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_0_modifier_poison_stack", "heroes/shadow/shadow_0_modifier_poison_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_2_modifier_smoke", "heroes/shadow/shadow_2_modifier_smoke", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shadow_2_modifier_vacuum", "heroes/shadow/shadow_2_modifier_vacuum", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("_modifier_blind", "modifiers/_modifier_blind", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_blind_stack", "modifiers/_modifier_blind_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

	function shadow_2__smoke:CalcStatus(duration, caster, target)
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

	function shadow_2__smoke:AddBonus(string, target, const, percent, time)
		local att = target:FindAbilityByName(string)
		if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
	end

	function shadow_2__smoke:RemoveBonus(string, target)
		local stringFormat = string.format("%s_modifier_stack", string)
		local mod = target:FindAllModifiersByName(stringFormat)
		for _,modifier in pairs(mod) do
			if modifier:GetAbility() == self then modifier:Destroy() end
		end
	end

	function shadow_2__smoke:GetRank(upgrade)
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		local att = caster:FindAbilityByName("shadow__attributes")
		if not att then return end
		if not att:IsTrained() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_phantom_assassin" then return end

		return att.talents[2][upgrade]
	end

	function shadow_2__smoke:OnUpgrade()
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_phantom_assassin" then return end

		local att = caster:FindAbilityByName("shadow__attributes")
		if att then
			if att:IsTrained() then
				att.talents[2][0] = true
			end
		end
		
		if self:GetLevel() == 1 then
			caster:FindAbilityByName("_2_DEX"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_DEF"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_RES"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_REC"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_MND"):CheckLevelUp(true)
			caster:FindAbilityByName("_2_LCK"):CheckLevelUp(true)
		end

		local charges = 1

		-- UP 2.2
		if self:GetRank(2) then
			charges = charges * 2
		end
		
		self:SetCurrentAbilityCharges(charges)
	end

	function shadow_2__smoke:Spawn()
		self:SetCurrentAbilityCharges(0)
	end

-- SPELL STAR

	function shadow_2__smoke:GetAOERadius()
		return (320 + ((self:GetLevel() - 1) * 10))
	end

	function shadow_2__smoke:OnSpellStart()
		local caster = self:GetCaster()
		local point = self:GetCursorPosition()
		local radius = self:GetAOERadius()
		local pull_radius = radius

		-- UP 2.3
		if self:GetRank(3) then
			pull_radius = radius + 150
		end

		local enemies = FindUnitsInRadius(
			caster:GetTeamNumber(),	-- int, your team number
			point,	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			pull_radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		for _,enemy in pairs(enemies) do
			enemy:AddNewModifier(
				caster, -- player source
				self, -- ability source
				"shadow_2_modifier_vacuum", -- modifier name
				{
					duration = 0.3,
					x = point.x,
					y = point.y,
				} -- kv
			)
		end

		local thinkers = Entities:FindAllByClassname("npc_dota_thinker")
		for _,smoke in pairs(thinkers) do
			if smoke:GetOwner() == caster and smoke:HasModifier("shadow_2_modifier_smoke") then
				smoke:Kill(self, nil)
			end
		end

		CreateModifierThinker(caster, self, "shadow_2_modifier_smoke", {radius = radius}, point, caster:GetTeamNumber(), false)

		GridNav:DestroyTreesAroundPoint( point, radius * 0.8, false )
		if IsServer() then caster:EmitSound("Hero_Dark_Seer.Vacuum") end
		self:PlayEffects( point, radius )
	end

	function shadow_2__smoke:GetCooldown(iLevel)
		if self:GetCurrentAbilityCharges() == 0 then return 21 end
		if self:GetCurrentAbilityCharges() == 1 then return 21 end
		if self:GetCurrentAbilityCharges() % 2 == 0 then return 18 end
	end

-- EFFECTS

	function shadow_2__smoke:PlayEffects( point, radius )
		local particle_cast = "particles/units/heroes/hero_dark_seer/dark_seer_vacuum.vpcf"
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl( effect_cast, 0, point )
		ParticleManager:SetParticleControl( effect_cast, 1, Vector( radius, radius, radius ) )
		ParticleManager:ReleaseParticleIndex( effect_cast )
	end