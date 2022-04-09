bocuse_2__flambee = class ({})
LinkLuaModifier("bocuse_2_modifier_casting", "heroes/bocuse/bocuse_2_modifier_casting", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_2_modifier_flambee_buff", "heroes/bocuse/bocuse_2_modifier_flambee_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_2_modifier_flambee_debuff", "heroes/bocuse/bocuse_2_modifier_flambee_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_blind", "modifiers/_modifier_blind", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_blind_stack", "modifiers/_modifier_blind_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

	function bocuse_2__flambee:CalcStatus(duration, caster, target)
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

	function bocuse_2__flambee:AddBonus(string, target, const, percent, time)
        local att = target:FindAbilityByName(string)
        if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
    end

	function bocuse_2__flambee:RemoveBonus(string, target)
		local stringFormat = string.format("%s_modifier_stack", string)
		local mod = target:FindAllModifiersByName(stringFormat)
		for _,modifier in pairs(mod) do
			if modifier:GetAbility() == self then modifier:Destroy() end
		end
	end

	function bocuse_2__flambee:GetRank(upgrade)
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		local att = caster:FindAbilityByName("bocuse__attributes")
		if not att then return end
		if not att:IsTrained() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_pudge" then return end

		return att.talents[2][upgrade]
	end

	function bocuse_2__flambee:OnUpgrade()
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_pudge" then return end

		local att = caster:FindAbilityByName("bocuse__attributes")
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

		-- UP 2.12
		if self:GetRank(12) then
			charges = charges * 2
		end

		self:SetCurrentAbilityCharges(charges)
	end

	function bocuse_2__flambee:Spawn()
        self:SetCurrentAbilityCharges(0)
    end

-- SPELL START

	function bocuse_2__flambee:GetAOERadius()
		return self:GetSpecialValueFor( "radius" )
	end

	function bocuse_2__flambee:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local range = self:GetCastRange(caster:GetOrigin(), nil)
		
		if target == caster then
			caster:StartGestureWithPlaybackRate(1602, 0.75)
			if IsServer() then
				caster:EmitSound("DOTA_Item.HealingSalve.Activate")
				caster:EmitSound("Hero_Brewmaster.Brawler.Crit")
			end
			self:PlayEfxFire(caster)
			self:BreakFlask(target, caster:GetOrigin())
			return
		end
		
		caster:AddNewModifier(caster, self, "bocuse_2_modifier_casting", {duration = 0.6})

		local projectile_name = "particles/bocuse/bocuse_flambee.vpcf"
		local projectile_speed = self:GetSpecialValueFor("projectile_speed")

		local info = {
			Target = target,
			Source = caster,
			Ability = self,	
			
			EffectName = projectile_name,
			iMoveSpeed = projectile_speed,
			bDodgeable = true,
		}

		Timers:CreateTimer((0.35), function()
			if self == nil then return end
			caster = self:GetCaster()
			target = self:GetCursorTarget()
			range = self:GetCastRange(caster:GetOrigin(), nil)
			projectile_name = "particles/bocuse/bocuse_flambee.vpcf"
			projectile_speed = self:GetSpecialValueFor("projectile_speed")

			if IsValidEntity(target) then
				ProjectileManager:CreateTrackingProjectile(info)
				self:PlayEfxCast()
			end

			-- UP 2.32
			if self:GetRank(32) then
				if caster:GetMana() < self:GetManaCost(-1) then return end
				local reverse_target = nil
				local team = DOTA_UNIT_TARGET_TEAM_FRIENDLY
				if target:GetTeamNumber() == caster:GetTeamNumber() then
					team = DOTA_UNIT_TARGET_TEAM_ENEMY
				end
				
				local units = FindUnitsInRadius(
					caster:GetTeamNumber(),	-- int, your team number
					caster:GetOrigin(),	-- point, center point
					nil,	-- handle, cacheUnit. (not known)
					range,	-- float, radius. or use FIND_UNITS_EVERYWHERE
					team,	-- int, team filter
					DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
					DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE,	-- int, flag filter
					0,	-- int, order filter
					false	-- bool, can grow cache
				)
			
				for _,unit in pairs(units) do
					if not (unit == caster) and unit:IsHero() and reverse_target == nil then
						reverse_target = unit
						break
					end
				end

				if reverse_target == nil then
					for _,unit in pairs(units) do
						if not (unit == caster) and reverse_target == nil then
							reverse_target = unit
							break
						end
					end
				end

				local reverse_info = {
					Target = reverse_target,
					Source = caster,
					Ability = self,	
					
					EffectName = projectile_name,
					iMoveSpeed = projectile_speed,
					bDodgeable = true,
				}

				if reverse_target then
					--caster:SpendMana(self:GetManaCost(-1) * 0.5, self)
					ProjectileManager:CreateTrackingProjectile(reverse_info)
					self:PlayEfxCast()
				end
			end
		end)
	end

	function bocuse_2__flambee:OnProjectileHit( target, location )
		if not target then return end
		if target:TriggerSpellAbsorb( self ) then return end

		if IsServer() then target:EmitSound("Hero_OgreMagi.Ignite.Target") end
		self:BreakFlask(target, location)
	end

	function bocuse_2__flambee:BreakFlask(target, location)
		local caster = self:GetCaster()
		local duration = self:GetSpecialValueFor("duration")
		local radius = self:GetSpecialValueFor("radius")
		local team = DOTA_UNIT_TARGET_TEAM_ENEMY
		if target:GetTeamNumber() == caster:GetTeamNumber() then
			team = DOTA_UNIT_TARGET_TEAM_FRIENDLY
		end

		local damageTable = {
			--victim = nil,
			attacker = caster,
			damage = 75,
			damage_type = DAMAGE_TYPE_MAGICAL,
			ability = self
		}

		local units = FindUnitsInRadius(
			caster:GetTeamNumber(),	-- int, your team number
			location,	-- point, center point
			nil,	-- handle, cacheUnit. (not known)
			radius,	-- float, radius. or use FIND_UNITS_EVERYWHERE
			team,	-- int, team filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
			0,	-- int, flag filter
			0,	-- int, order filter
			false	-- bool, can grow cache
		)

		for _,unit in pairs(units) do
			if team == DOTA_UNIT_TARGET_TEAM_FRIENDLY then
				-- UP 2.11
				if self:GetRank(11) then
					unit:Purge(false, true, false, true, false)
				end
				unit:AddNewModifier(caster, self, "bocuse_2_modifier_flambee_buff", {duration = self:CalcStatus(duration, caster, unit)})
			else
				-- UP 2.11
				if self:GetRank(11) then
					damageTable.victim = unit
					ApplyDamage(damageTable)
				end
				unit:AddNewModifier(caster, self, "bocuse_2_modifier_flambee_debuff", {duration = self:CalcStatus(duration, caster, unit)})
			end
			self:PlayEfxFire(unit)
		end

		self:PlayEfxImpact(target, location)
		GridNav:DestroyTreesAroundPoint(location, radius , false)
	end

	function bocuse_2__flambee:CastFilterResultTarget( hTarget )
		local caster = self:GetCaster()
		if caster == hTarget then
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

	function bocuse_2__flambee:GetCooldown(iLevel)
		if self:GetCurrentAbilityCharges() == 0 then return 24 end
		if self:GetCurrentAbilityCharges() == 1 then return 24 end
		if self:GetCurrentAbilityCharges() % 2 == 0 then return 20 end
	end

--EFFECTS

	function bocuse_2__flambee:PlayEfxImpact(target, location)
		local particle_cast = "particles/bocuse/bocuse_flambee_impact.vpcf"
		local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, target)
		ParticleManager:SetParticleControl(effect_cast, 0, location)
		ParticleManager:SetParticleControl(effect_cast, 1, Vector(200,200,200))

		particle_cast = "particles/econ/items/alchemist/alchemist_smooth_criminal/alchemist_smooth_criminal_unstable_concoction_explosion.vpcf"
		effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, target)
		ParticleManager:SetParticleControl(effect_cast, 0, location)
	end

	function bocuse_2__flambee:PlayEfxFire(target)
		local particle_cast = "particles/bocuse/bocuse_flambee_impact_fire_ring.vpcf"
		local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, target)
		ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
	end

	function bocuse_2__flambee:PlayEfxCast()
		if IsServer() then self:GetCaster():EmitSound("Hero_OgreMagi.Ignite.Cast") end
	end

-- particles/econ/items/phoenix/phoenix_ti10_immortal/phoenix_ti10_fire_spirit_ground.vpcf
-- particles/econ/items/pudge/pudge_ti6_immortal/pudge_meathook_impact_ti6.vpcf
-- ult particles/econ/items/void_spirit/void_spirit_immortal_2021/void_spirit_immortal_2021_astral_step_dmg.vpcf
-- particles/econ/items/doom/doom_ti8_immortal_arms/doom_ti8_immortal_devour.vpcf