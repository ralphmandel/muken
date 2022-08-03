bocuse_2__flambee = class ({})
LinkLuaModifier("bocuse_2_modifier_casting", "heroes/bocuse/bocuse_2_modifier_casting", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_2_modifier_flambee_buff", "heroes/bocuse/bocuse_2_modifier_flambee_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_2_modifier_flambee_debuff", "heroes/bocuse/bocuse_2_modifier_flambee_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_2_modifier_status_efx", "heroes/bocuse/bocuse_2_modifier_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_blind", "modifiers/_modifier_blind", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_blind_stack", "modifiers/_modifier_blind_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

	function bocuse_2__flambee:CalcStatus(duration, caster, target)
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

	function bocuse_2__flambee:AddBonus(string, target, const, percent, time)
        local base_stats = target:FindAbilityByName("base_stats")
        if base_stats then base_stats:AddBonusStat(self:GetCaster(), self, const, percent, time, string) end
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
		if caster:GetUnitName() ~= "npc_dota_hero_pudge" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then return base_hero.ranks[2][upgrade] end
	end

	function bocuse_2__flambee:OnUpgrade()
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_pudge" then return end

		local base_hero = caster:FindAbilityByName("base_hero")
        if base_hero then base_hero.ranks[2][0] = true end

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

	function bocuse_2__flambee:OnAbilityPhaseStart()
		local caster = self:GetCaster()
		self.target = self:GetCursorTarget()
		caster:RemoveModifierByNameAndCaster("bocuse_2_modifier_casting", caster)
		caster:AddNewModifier(caster, self, "bocuse_2_modifier_casting", {duration = 1})
		return true
	end

	function bocuse_2__flambee:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		local range = self:GetCastRange(caster:GetOrigin(), nil)
		
		if target == caster then
			if IsServer() then
				caster:EmitSound("DOTA_Item.HealingSalve.Activate")
				caster:EmitSound("Hero_Brewmaster.Brawler.Crit")
			end

			self:PlayEfxFire(caster)
			self:BreakFlask(target, caster:GetOrigin())
			return
		end

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

		ProjectileManager:CreateTrackingProjectile(info)
		if IsServer() then caster:EmitSound("Hero_OgreMagi.Ignite.Cast") end

		-- UP 2.31
		if self:GetRank(31) then
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
			
			if reverse_target then
				info.Target = reverse_target
				ProjectileManager:CreateTrackingProjectile(info)
			end
		end
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

		AddFOWViewer(caster:GetTeamNumber(), caster:GetOrigin(), radius, 1, true)

		if target:GetTeamNumber() == caster:GetTeamNumber() then
			team = DOTA_UNIT_TARGET_TEAM_FRIENDLY
		end

		local damageTable = {
			--victim = nil,
			attacker = caster,
			damage = 125,
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
				-- UP 2.22
				if self:GetRank(22) then
					unit:Purge(false, true, false, true, false)
				end
				unit:AddNewModifier(caster, self, "bocuse_2_modifier_flambee_buff", {
					duration = self:CalcStatus(duration, caster, unit)
				})
			else
				if unit:IsInvulnerable() == false then
					-- UP 2.22
					if self:GetRank(22) then
						damageTable.victim = unit
						ApplyDamage(damageTable)
					end
					unit:AddNewModifier(caster, self, "bocuse_2_modifier_flambee_debuff", {
						duration = self:CalcStatus(duration, caster, unit)
					})
				end
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
        local cooldown = self:GetSpecialValueFor("cooldown")
		if self:GetCurrentAbilityCharges() == 0 then return cooldown end
		if self:GetCurrentAbilityCharges() == 1 then return cooldown end
		if self:GetCurrentAbilityCharges() % 2 == 0 then return cooldown - 4 end
        return cooldown
	end

	function bocuse_2__flambee:GetCastRange(vLocation, hTarget)
        return self:GetSpecialValueFor("range")
    end

	function bocuse_2__flambee:GetManaCost(iLevel)
        local manacost = self:GetSpecialValueFor("manacost")
        local level = (1 + ((self:GetLevel() - 1) * 0.05))
        if self:GetCurrentAbilityCharges() == 0 then return 0 end
        return manacost * level
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

-- particles/econ/items/phoenix/phoenix_ti10_immortal/phoenix_ti10_fire_spirit_ground.vpcf
-- particles/econ/items/pudge/pudge_ti6_immortal/pudge_meathook_impact_ti6.vpcf
-- ult particles/econ/items/void_spirit/void_spirit_immortal_2021/void_spirit_immortal_2021_astral_step_dmg.vpcf
-- particles/econ/items/doom/doom_ti8_immortal_arms/doom_ti8_immortal_devour.vpcf