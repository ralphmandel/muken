shadow_u__dagger = class({})
LinkLuaModifier( "shadow_u_modifier_dagger", "heroes/shadow/shadow_u_modifier_dagger", LUA_MODIFIER_MOTION_NONE )

-- INIT

	function shadow_u__dagger:CalcStatus(duration, caster, target)
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

	function shadow_u__dagger:AddBonus(string, target, const, percent, time)
		local att = target:FindAbilityByName(string)
		if att then att:BonusPts(self:GetCaster(), self, const, percent, time) end
	end

	function shadow_u__dagger:RemoveBonus(string, target)
		local stringFormat = string.format("%s_modifier_stack", string)
		local mod = target:FindAllModifiersByName(stringFormat)
		for _,modifier in pairs(mod) do
			if modifier:GetAbility() == self then modifier:Destroy() end
		end
	end

	function shadow_u__dagger:GetRank(upgrade)
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		local att = caster:FindAbilityByName("shadow__attributes")
		if not att then return end
		if not att:IsTrained() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_phantom_assassin" then return end

		return att.talents[4][upgrade]
	end

	function shadow_u__dagger:OnUpgrade()
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end
		if caster:GetUnitName() ~= "npc_dota_hero_phantom_assassin" then return end

		local att = caster:FindAbilityByName("shadow__attributes")
		if att then
			if att:IsTrained() then
				att.talents[4][0] = true
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
		
		-- UP 4.1
		if self:GetRank(1) then
			charges = charges * 2
		end

		-- UP 4.2
		if self:GetRank(2) then
			charges = charges * 3
		end

		self:SetCurrentAbilityCharges(charges)
	end

	function shadow_u__dagger:Spawn()
		self:SetCurrentAbilityCharges(0)
	end

-- SPELL START

	function shadow_u__dagger:GetIntrinsicModifierName()
		return "shadow_u_modifier_dagger"
	end

	function shadow_u__dagger:OnSpellStart()

		local caster = self:GetCaster()
		local target = self:GetCursorTarget()
		self.landed = true

		local projectile_name = "particles/units/heroes/hero_phantom_assassin/phantom_assassin_stifling_dagger.vpcf"
		local projectile_vision = 200
		local projectile_speed = self:GetSpecialValueFor("dagger_speed")

		-- UP 4.3
		if self:GetRank(3) then
			projectile_speed = projectile_speed * 2
		end

		-- Create Projectile
		local info = {
			Target = target,
			Source = caster,
			Ability = self,	
			EffectName = projectile_name,
			iMoveSpeed = projectile_speed,
			bReplaceExisting = false,                         -- Optional
			bProvidesVision = true,                           -- Optional
			iVisionRadius = projectile_vision,				-- Optional
			iVisionTeamNumber = caster:GetTeamNumber()        -- Optional
		}

		ProjectileManager:CreateTrackingProjectile(info)
		if IsServer() then caster:EmitSound("Hero_PhantomAssassin.Dagger.Cast") end
	end

	function shadow_u__dagger:OnProjectileHit(hTarget, vLocation)
		self.landed = false
		
		if hTarget == nil then return end
		if hTarget:IsInvulnerable() then return end
		if hTarget:TriggerSpellAbsorb( self ) then return end

		-- UP 4.2
		if self:GetRank(2) == false and hTarget:IsMagicImmune() then
			return
		end

		local caster = self:GetCaster()
		self.target_hero = hTarget
		if IsServer() then hTarget:EmitSound("Hero_PhantomAssassin.Dagger.Target") end

		if hTarget:HasModifier("shadow_0_modifier_poison") == false then return end

		local multiplier = self:GetSpecialValueFor("multiplier")
		local heal = self:GetSpecialValueFor("heal")

		-- UP 4.6
		if self:GetRank(6) then
			if RandomInt(1, 2) == 2 then
				multiplier = multiplier * 2
				self:PlayEfxCrit((hTarget:GetOrigin() - caster:GetOrigin()), caster:GetOrigin(), hTarget)
			end
		end

		self.respawn = hTarget:GetHealthPercent()
		self.damage = hTarget:FindModifierByName("shadow_0_modifier_poison"):GetTotalPoisonDamage() * multiplier * 0.01
		local hp_target = hTarget:GetHealth()

		local damageTable = {
			victim = hTarget,
			attacker = caster,
			damage = self.damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self
		}
		
		local total = ApplyDamage(damageTable)
		self:PlayEffects(hTarget)

		if hTarget:IsAlive() then
			caster:Heal(total * heal * 0.01, self) 
			hTarget:RemoveModifierByName("shadow_0_modifier_poison")
		else
			heal = heal * 1.5
			caster:Heal(hp_target * heal * 0.01, self)
			self:EndCooldown()
		end

		self.target_hero = nil
	end

	function shadow_u__dagger:GetTargetHit()
		return self.target_hero
	end

	function shadow_u__dagger:OnHeroDiedNearby(hVictim, hKiller, kv)
		if hVictim == nil or hKiller == nil or self.target_hero == nil then return end
		local caster = self:GetCaster()

		if hVictim:HasModifier("shadow_0_modifier_poison") and self.target_hero == hVictim then

			-- UP 4.5
			if self:GetRank(5) then
				self.respawn = self.respawn * 2
			end

			local new_respawnTime = hVictim:GetRespawnTime() + self.respawn
			hVictim:SetTimeUntilRespawn(new_respawnTime)
		end
	end

	function shadow_u__dagger:CastFilterResultTarget( hTarget )
		local caster = self:GetCaster()
		local flag = 0

		if caster == hTarget then
			return UF_FAIL_CUSTOM
		end

		-- UP 4.2
		if self:GetCurrentAbilityCharges() % 3 == 0 then
			flag = DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
		end

		local result = UnitFilter(
			hTarget,	-- Target Filter
			DOTA_UNIT_TARGET_TEAM_ENEMY,	-- Team Filter
			DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,	-- Unit Filter
			flag,	-- Unit Flag
			caster:GetTeamNumber()	-- Team reference
		)
		
		if result ~= UF_SUCCESS then
			return result
		end

		return UF_SUCCESS
	end

	function shadow_u__dagger:GetCustomCastErrorTarget( hTarget )
		if self:GetCaster() == hTarget then
			return "#dota_hud_error_cant_cast_on_self"
		end
	end

	function shadow_u__dagger:GetManaCost(iLevel)
		if self:GetCurrentAbilityCharges() == 0 then return 0 end
        if self:GetCurrentAbilityCharges() == 1 then return 100 end
        if self:GetCurrentAbilityCharges() % 2 == 0 then return 0 end
		return 100
	end

-- EFFECTS

	function shadow_u__dagger:PlayEffects( target )

		local particle_cast = "particles/econ/items/void_spirit/void_spirit_immortal_2021/void_spirit_immortal_2021_astral_step_dmg.vpcf"
		local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_ABSORIGIN, target )
		ParticleManager:SetParticleControl( effect_cast, 0, target:GetOrigin() )

		if IsServer() then target:EmitSound("Hero_QueenOfPain.ShadowStrike") end
	end

	function shadow_u__dagger:PlayEfxCrit(direction, origin, target)
		local particle_cast = "particles/units/heroes/hero_centaur/centaur_double_edge.vpcf"
		local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, target)
		ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
		ParticleManager:SetParticleControlForward(effect_cast, 0, direction:Normalized())
		ParticleManager:SetParticleControl(effect_cast, 1, origin + direction)
		ParticleManager:ReleaseParticleIndex(effect_cast)
		
		if IsServer() then target:EmitSound("Hero_PhantomAssassin.CoupDeGrace") end
	end