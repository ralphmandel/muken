inquisitor_3__blow = class({})
LinkLuaModifier("inquisitor_3_modifier_blow", "heroes/inquisitor/inquisitor_3_modifier_blow", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("inquisitor_3_modifier_dark", "heroes/inquisitor/inquisitor_3_modifier_dark", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("inquisitor_3_modifier_speed", "heroes/inquisitor/inquisitor_3_modifier_speed", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_ban", "modifiers/_modifier_ban", LUA_MODIFIER_MOTION_NONE)

-- INIT

	function inquisitor_3__blow:CalcStatus(duration, caster, target)
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

	function inquisitor_3__blow:AddBonus(string, target, const, percent, time)
		local att = target:FindAbilityByName(string)
		if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
	end

	function inquisitor_3__blow:RemoveBonus(string, target)
		local stringFormat = string.format("%s_modifier_stack", string)
		local mod = target:FindAllModifiersByName(stringFormat)
		for _,modifier in pairs(mod) do
			if modifier:GetAbility() == self then modifier:Destroy() end
		end
	end

	function inquisitor_3__blow:GetRank(upgrade)
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		local att = caster:FindAbilityByName("inquisitor__attributes")
		if not att then return end
		if not att:IsTrained() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

		return att.talents[3][upgrade]
	end

	function inquisitor_3__blow:OnUpgrade()
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_dawnbreaker" then return end

		local att = caster:FindAbilityByName("inquisitor__attributes")
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

		-- UP 3.5
		if self:GetRank(5) then
			charges = charges * 2
		end

		self:SetCurrentAbilityCharges(charges)
	end

	function inquisitor_3__blow:Spawn()
		self:SetCurrentAbilityCharges(0)
		self.autocast = false
	end

-- SPELL START

	function inquisitor_3__blow:OnSpellStart()
		local caster = self:GetCaster()
		self.target = self:GetCursorTarget()
		local direction = (self.target:GetOrigin() - caster:GetOrigin())
		local autocast = 0

		if self.target:TriggerSpellAbsorb( self ) then
			self.autocast = false
			return
		end

		-- UP 3.5
		if self:GetRank(5) then
			local blow = caster:FindModifierByName("inquisitor_3_modifier_blow")
			if blow then
				if blow.autocast == 0 then self.autocast = false end
			end
		end

		caster:RemoveModifierByName("inquisitor_3_modifier_blow")
		caster:AddNewModifier(caster, self, "inquisitor_3_modifier_speed", {})
		self:AddBonus("_1_AGI", caster, 0, -500, nil)
		self:PlayEfxBlinkStart(direction, self.target)

		caster:Stop()
		caster:AddNewModifier(caster, self, "_modifier_ban", {})
		if self.autocast then autocast = 1 end

		Timers:CreateTimer((0.1), function()
			if self.target then
				if IsValidEntity(self.target) then
					local new_pos = self:RandonizePoint(self.target:GetOrigin(), 350)
					FindClearSpaceForUnit(caster, new_pos, true)

					local mod = caster:FindAllModifiersByName("_modifier_ban")
					for _,modifier in pairs(mod) do
						if modifier:GetAbility() == self then modifier:Destroy() end
					end

					caster:MoveToTargetToAttack(self.target)
					caster:AddNewModifier(caster, self, "inquisitor_3_modifier_blow", {autocast = autocast})
					return				
				end
			end
			caster:RemoveModifierByName("inquisitor_3_modifier_speed")
			self:RemoveBonus("_1_AGI", caster)
		end)

		self.autocast = false
	end

	function inquisitor_3__blow:OnSpellDark()
		local caster = self:GetCaster()
		self.target = self:GetCursorTarget()
		if self.target:GetTeamNumber() == caster:GetTeamNumber() then return end
		local direction = (self.target:GetOrigin() - caster:GetOrigin())

		caster:RemoveModifierByName("inquisitor_3_modifier_blow")
		caster:AddNewModifier(caster, self, "inquisitor_3_modifier_speed", {})
		self:AddBonus("_1_AGI", caster, 0, -500, nil)
		self:PlayEfxBlinkStart(direction, self.target)

		caster:Stop()
		caster:AddNewModifier(caster, self, "_modifier_ban", {})

		Timers:CreateTimer((0.1), function()
			if self.target then
				if IsValidEntity(self.target) then
					local new_pos = self:RandonizePoint(self.target:GetOrigin(), 350)
					FindClearSpaceForUnit(caster, new_pos, true)

					local mod = caster:FindAllModifiersByName("_modifier_ban")
					for _,modifier in pairs(mod) do
						if modifier:GetAbility() == self then modifier:Destroy() end
					end

					caster:MoveToTargetToAttack(self.target)
					caster:AddNewModifier(caster, self, "inquisitor_3_modifier_dark", {duration = 7.5})		
					return		
				end
			end
			caster:RemoveModifierByName("inquisitor_3_modifier_speed")
			self:RemoveBonus("_1_AGI", caster)
		end)
	end

	function inquisitor_3__blow:ReloadTarget()
		local caster = self:GetCaster()
		if caster:HasModifier("inquisitor_3_modifier_dark") == false then return end
		local new_target = true

		if self.target then
			if IsValidEntity(self.target) then
				local result = UnitFilter(
					self.target,	-- Target Filter
					DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
					DOTA_UNIT_TARGET_HERO,	-- Unit Filter
					DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE,	-- Unit Flag
					caster:GetTeamNumber()	-- Team reference
				)
				if result == UF_SUCCESS and self.target:IsInvisible() == false then new_target = false end
			end
		end

		if new_target == true then
			local find = false
			local heroes = FindUnitsInRadius(
				caster:GetTeamNumber(),	-- int, your team number
				caster:GetOrigin(),	-- point, center point
				nil,	-- handle, cacheUnit. (not known)
				500,	-- float, radius. or use FIND_UNITS_EVERYWHERE
				DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
				DOTA_UNIT_TARGET_HERO,	-- int, type filter
				DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_NOT_ATTACK_IMMUNE,	-- int, flag filter
				1,	-- int, order filter
				false	-- bool, can grow cache
			)
		
			for _,hero in pairs(heroes) do
				if hero:IsInvisible() == false then
					self.target = hero
					find = true
					break
				end
			end

			if find == false then
				caster:RemoveModifierByName("inquisitor_3_modifier_dark")
				return
			end
		end

		local direction = (self.target:GetOrigin() - caster:GetOrigin())

		self:PlayEfxBlinkStart(direction, self.target)

		caster:Stop()
		caster:AddNewModifier(caster, self, "_modifier_ban", {})

		Timers:CreateTimer((0.1), function()
			if self.target then
				if IsValidEntity(self.target) then
					local new_pos = self:RandonizePoint(self.target:GetOrigin(), 350)
					FindClearSpaceForUnit(caster, new_pos, true)

					local mod = caster:FindAllModifiersByName("_modifier_ban")
					for _,modifier in pairs(mod) do
						if modifier:GetAbility() == self then modifier:Destroy() end
					end

					caster:MoveToTargetToAttack(self.target)
					local dark = caster:FindModifierByName("inquisitor_3_modifier_dark")
					if dark then
						if dark:GetCaster() == caster then
							dark:OnRefresh()
						end
					end
				end
			end
		end)
	end

	function inquisitor_3__blow:RandonizePoint(point, distance)
		local caster = self:GetCaster()
		local random_x
		local random_y

		local quarter = RandomInt(1,4)
		if quarter == 1 then
			random_x = RandomInt(-distance, distance)
			random_y = -distance
		elseif quarter == 2 then
			random_x = RandomInt(-distance, distance)
			random_y = distance
		elseif quarter == 3 then
			random_x = -distance
			random_y = RandomInt(-distance, distance)
		elseif quarter == 4 then
			random_x = distance
			random_y = RandomInt(-distance, distance)
		end

		local x = self:CalculateAngle( random_x, random_y)
		local y = self:CalculateAngle( random_y, random_x)

		point.x = point.x + x
		point.y = point.y + y

		self:PlayEfxBlinkEnd(point)

		local blinkDirection = (point - self.target:GetOrigin()):Normalized() * 175
		point = self.target:GetOrigin() + blinkDirection
		
		GridNav:DestroyTreesAroundPoint(point, 150, false)
		return point
	end

	function inquisitor_3__blow:CalculateAngle(a, b)
		if a < 0 then
			if b > 0 then b = -b end
		else
			if b < 0 then b = -b end
		end
		return a - math.floor(b/4)
	end

	function inquisitor_3__blow:EnableAutoCast()
		self.autocast = true
	end

	function inquisitor_3__blow:GetCastRange(vLocation, hTarget)
		if self:GetCurrentAbilityCharges() == 0 then return 250 end
		if self:GetCurrentAbilityCharges() == 1 then return 250 end
		if self:GetCurrentAbilityCharges() % 2 == 0 then return 750 end
	end

-- EFFECTS

	function inquisitor_3__blow:PlayEfxBlinkStart(direction, target)
		local caster = self:GetCaster()
		local particle_cast = "particles/econ/events/ti10/blink_dagger_start_ti10_splash.vpcf"
		
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl( effect_cast, 0, caster:GetOrigin() )
		ParticleManager:SetParticleControlForward( effect_cast, 0, direction:Normalized() )
		ParticleManager:SetParticleControl( effect_cast, 1, target:GetOrigin() + direction )
		ParticleManager:ReleaseParticleIndex( effect_cast )

		if IsServer() then caster:EmitSound("Hero_Antimage.Blink_out") end
	end

	function inquisitor_3__blow:PlayEfxBlinkEnd(new_pos)
		local caster = self:GetCaster()
		local direction = self.target:GetOrigin() - new_pos
		local particle_cast_a = "particles/econ/items/phantom_assassin/pa_fall20_immortal_shoulders/pa_fall20_blur_start.vpcf"
		local particle_cast_b = "particles/econ/events/ti10/blink_dagger_end_ti10_lvl2.vpcf"
		
		local effect_cast_a = ParticleManager:CreateParticle(particle_cast_a, PATTACH_WORLDORIGIN, nil)
		ParticleManager:SetParticleControl(effect_cast_a, 0, new_pos)
		ParticleManager:SetParticleControlForward(effect_cast_a, 0, direction:Normalized())
		ParticleManager:SetParticleControl(effect_cast_a, 1, new_pos + direction )
		ParticleManager:ReleaseParticleIndex(effect_cast_a)

		local effect_cast_b = ParticleManager:CreateParticle( particle_cast_b, PATTACH_WORLDORIGIN, nil )
		ParticleManager:SetParticleControl(effect_cast_b, 0, caster:GetOrigin())
		ParticleManager:SetParticleControlForward( effect_cast_b, 0, direction:Normalized())
		ParticleManager:ReleaseParticleIndex(effect_cast_b)

		if IsServer() then caster:EmitSound("Hero_Antimage.Blink_in.Persona") end
	end