bocuse_2__flambee = class({})
LinkLuaModifier("bocuse_2_modifier_flambee", "heroes/bocuse/bocuse_2_modifier_flambee", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_2_modifier_flambee_status_efx", "heroes/bocuse/bocuse_2_modifier_flambee_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_blind", "modifiers/_modifier_blind", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_blind_stack", "modifiers/_modifier_blind_stack", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function bocuse_2__flambee:GetAOERadius()
		return self:GetSpecialValueFor("radius")
	end

	function bocuse_2__flambee:OnAbilityPhaseStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()

		if caster == target then
			--BaseHeroMod(caster):ChangeActivity("trapper")
			caster:StartGestureWithPlaybackRate(ACT_DOTA_VICTORY, 2)
		else
			local rand = RandomInt(1,3)
			--if rand == 1 then self.parent:AddActivityModifier("ti10_pudge") end
      if BaseHeroMod(caster) then
        if rand == 1 then BaseHeroMod(caster):ChangeActivity("") end
        if rand == 2 then BaseHeroMod(caster):ChangeActivity("ftp_dendi_back") end
        if rand == 3 then BaseHeroMod(caster):ChangeActivity("trapper") end
        caster:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
      end
		end

		return true
	end

	function bocuse_2__flambee:OnAbilityPhaseInterrupted()
		local caster = self:GetCaster()
		if BaseHeroMod(caster) then
      BaseHeroMod(caster):ChangeActivity("trapper")
      caster:FadeGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
      caster:FadeGesture(ACT_DOTA_VICTORY)
    end
	end

	function bocuse_2__flambee:OnSpellStart()
		local caster = self:GetCaster()
		local target = self:GetCursorTarget()

		if target:GetTeamNumber() ~= caster:GetTeamNumber()
		and target:TriggerSpellAbsorb(self) then
			return
		end

		if BaseHeroMod(caster) then BaseHeroMod(caster):ChangeActivity("trapper") end

		if caster == target then
			Timers:CreateTimer(0.6, function()
				caster:FadeGesture(ACT_DOTA_VICTORY)
			end)
				
			self:BreakFlask(target)
			return
		end
		
		caster:FadeGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
		caster:StartGesture(ACT_DOTA_CHANNEL_ABILITY_1)

		self:CreateFLask(caster, target)
		self:ThrowSecondFlask(target)		
	end

	function bocuse_2__flambee:ThrowSecondFlask(target)
		if self:GetSpecialValueFor("special_second_flask") == 0 then return end

		local caster = self:GetCaster()
		local target_team = DOTA_UNIT_TARGET_TEAM_FRIENDLY

		if caster:GetTeamNumber() == target:GetTeamNumber() then
			target_team = DOTA_UNIT_TARGET_TEAM_ENEMY
		end

		local units = FindUnitsInRadius(
			caster:GetTeamNumber(), caster:GetOrigin(), nil, self:GetCastRange(caster:GetOrigin(), nil),
			target_team, self:GetAbilityTargetType(), self:GetAbilityTargetFlags(),
			FIND_ANY_ORDER, false
		)

		for _,unit in pairs(units) do
			if unit ~= caster then
				self:CreateFLask(caster, unit)
				break
			end
		end
	end

	function bocuse_2__flambee:CreateFLask(caster, target)
		if IsServer() then caster:EmitSound("Hero_OgreMagi.Ignite.Cast") end

		ProjectileManager:CreateTrackingProjectile({
			Target = target,
			Source = caster,
			Ability = self,	

			EffectName = "particles/bocuse/bocuse_flambee.vpcf",
			iMoveSpeed = self:GetSpecialValueFor("projectile_speed"),
			bDodgeable = false
		})
	end

	function bocuse_2__flambee:OnProjectileHit(hTarget, vLocation)
		if not hTarget then return end
		self:BreakFlask(hTarget)
	end

	function bocuse_2__flambee:BreakFlask(target)
		local caster = self:GetCaster()
		local radius = self:GetAOERadius()
		local target_team = DOTA_UNIT_TARGET_TEAM_ENEMY

		if caster:GetTeamNumber() == target:GetTeamNumber() then
			target_team = DOTA_UNIT_TARGET_TEAM_FRIENDLY
		end

		local units = FindUnitsInRadius(
			caster:GetTeamNumber(), target:GetOrigin(), nil, radius,
			target_team, self:GetAbilityTargetType(),
			self:GetAbilityTargetFlags(), 0, false
		)

		for _,unit in pairs(units) do
			self:PlayEfxHit(unit)			
			unit:AddNewModifier(caster, self, "bocuse_2_modifier_flambee", {
				duration = self:GetSpecialValueFor("duration") + 0.1
			})
		end

		self:PlayEfxImpact(target, radius)
		GridNav:DestroyTreesAroundPoint(target:GetOrigin(), radius , false)
		AddFOWViewer(caster:GetTeamNumber(), caster:GetOrigin(), radius, 1, true)
	end

-- EFFECTS

	function bocuse_2__flambee:PlayEfxImpact(target, radius)
		local caster = self:GetCaster()
		local particle_cast = "particles/bocuse/bocuse_flambee_impact.vpcf"
		local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, target)
		ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
		ParticleManager:SetParticleControl(effect_cast, 1, Vector(radius, radius, radius))
		ParticleManager:ReleaseParticleIndex(effect_cast)

		particle_cast = "particles/econ/items/alchemist/alchemist_smooth_criminal/alchemist_smooth_criminal_unstable_concoction_explosion.vpcf"
		effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, target)
		ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
		ParticleManager:ReleaseParticleIndex(effect_cast)

		if IsServer() then
			if caster == target then
				target:EmitSound("DOTA_Item.HealingSalve.Activate")
				target:EmitSound("Hero_Brewmaster.Brawler.Crit")
			else
				target:EmitSound("Hero_OgreMagi.Ignite.Target")
			end
		end
	end

	function bocuse_2__flambee:PlayEfxHit(target)
		local particle_cast = "particles/bocuse/bocuse_flambee_impact_fire_ring.vpcf"
		local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, target)
		ParticleManager:SetParticleControl(effect_cast, 0, target:GetOrigin())
	end