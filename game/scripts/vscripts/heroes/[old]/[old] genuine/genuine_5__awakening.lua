genuine_5__awakening = class({})
LinkLuaModifier("genuine_5_modifier_passive", "heroes/team_moon/genuine/genuine_5_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_5_modifier_channeling", "heroes/team_moon/genuine/genuine_5_modifier_channeling", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "_modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

	genuine_5__awakening.projectiles = {}

-- SPELL START

	function genuine_5__awakening:GetIntrinsicModifierName()
		return "genuine_5_modifier_passive"
	end

	function genuine_5__awakening:OnSpellStart()
		local caster = self:GetCaster()
		local time = self:GetChannelTime()
		local gesture_time = 0.4
		local rate = 1 / (time / gesture_time)

		caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_2, rate)
		caster:FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), caster):DecrementStackCount()
    caster:AddNewModifier(caster, self, "genuine_5_modifier_channeling", {})

		self:PlayEfxChannel(self:GetCursorPosition(), time * 100)
	end

	function genuine_5__awakening:OnChannelFinish(bInterrupted)
		local caster = self:GetCaster()
		local point = self:GetCursorPosition()
		local channel_pct = (GameRules:GetGameTime() - self:GetChannelStartTime()) / self:GetChannelTime()
    channel_pct = (channel_pct * 0.8) + 0.2
    caster:RemoveModifierByName("genuine_5_modifier_channeling")

		Timers:CreateTimer((0.1), function()
			caster:FadeGesture(ACT_DOTA_CAST_ABILITY_2)
		end)

		local projectile_name = "particles/genuine/genuine_powershoot/genuine_spell_powershot_ti6.vpcf"
		local damage_reduction = 1 - (self:GetSpecialValueFor("damage_reduction") * 0.01)
		local projectile_direction = point-caster:GetOrigin()
		projectile_direction.z = 0
		projectile_direction = projectile_direction:Normalized()

    local fDistance = self:GetCastRange(caster:GetAbsOrigin(), nil) * channel_pct
    if fDistance < 500 then fDistance = 500 end

		local projectile = ProjectileManager:CreateLinearProjectile({
			Source = caster,
			Ability = self,
			vSpawnOrigin = caster:GetAbsOrigin(),
			
			iUnitTargetTeam = self:GetAbilityTargetTeam(),
			iUnitTargetType = self:GetAbilityTargetType(),
			iUnitTargetFlags = self:GetAbilityTargetFlags(),

			EffectName = projectile_name,
			fDistance = fDistance,
			fStartRadius = self:GetSpecialValueFor("arrow_width"),
			fEndRadius = self:GetSpecialValueFor("arrow_width"),
			vVelocity = projectile_direction * self:GetSpecialValueFor("arrow_speed"),
	
			bProvidesVision = true,
			iVisionRadius = self:GetSpecialValueFor("vision_radius"),
			iVisionTeamNumber = caster:GetTeamNumber(),
		})

		self.projectiles[projectile] = {}
		self.projectiles[projectile].damage = self:GetSpecialValueFor("damage") * channel_pct
		self.projectiles[projectile].reduction = damage_reduction
		self.projectiles[projectile].knockbackProperties = {
			center_x = caster:GetAbsOrigin().x + 1,
			center_y = caster:GetAbsOrigin().y + 1,
			center_z = caster:GetAbsOrigin().z,
			knockback_height = 0,
			duration = self:GetSpecialValueFor("special_bash_power") / 2000,
			knockback_duration = self:GetSpecialValueFor("special_bash_power") / 2000,
			knockback_distance = self:GetSpecialValueFor("special_bash_power") * channel_pct
		} --700

		self:StopEfxChannel()
	end

	function genuine_5__awakening:OnProjectileHitHandle(target, location, handle)
		local caster = self:GetCaster()

		if not target then
			self.projectiles[handle] = nil

			local vision_radius = self:GetSpecialValueFor("vision_radius")
			local vision_duration = self:GetSpecialValueFor("vision_duration")
			AddFOWViewer(caster:GetTeamNumber(), location, vision_radius, vision_duration, false)

			return
		end

		local data = self.projectiles[handle]
		local damage = data.damage

		if data.knockbackProperties.knockback_distance > 0 and target:IsAlive() then
			target:AddNewModifier(caster, nil, "modifier_knockback", data.knockbackProperties)
			target:AddNewModifier(caster, self, "_modifier_movespeed_debuff", {percent = 300, duration = 1})
		end

		if IsServer() then target:EmitSound("Hero_Windrunner.PowershotDamage") end

		ApplyDamage({
			victim = target,
			attacker = caster,
			damage = damage,
			damage_type = self:GetAbilityDamageType(),
			ability = self
		})

		data.damage = damage * data.reduction
	end

	function genuine_5__awakening:OnProjectileThink(location)
		local tree_width = self:GetSpecialValueFor("tree_width")
		GridNav:DestroyTreesAroundPoint(location, tree_width, false)	
	end

	function genuine_5__awakening:GetChannelTime()
		local channel = self:GetCaster():FindAbilityByName("_channel")
		local channel_time = self:GetSpecialValueFor("channel_time")
		return channel_time * (1 - (channel:GetLevel() * channel:GetSpecialValueFor("channel") * 0.01))
	end

-- EFFECTS

	function genuine_5__awakening:PlayEfxChannel(point, time)
		local caster = self:GetCaster()
		local particle_cast = "particles/genuine/genuine_powershoot/genuine_powershot_channel_combo_v2.vpcf"
		local direction = point - caster:GetAbsOrigin()

		if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, true) end
		self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, caster)
		ParticleManager:SetParticleControl(self.effect_cast, 0, caster:GetOrigin())
		ParticleManager:SetParticleControlForward(self.effect_cast, 0, direction:Normalized())
		ParticleManager:SetParticleControl(self.effect_cast, 1, caster:GetOrigin())
		ParticleManager:SetParticleControlForward(self.effect_cast, 1, direction:Normalized())
		ParticleManager:SetParticleControl(self.effect_cast, 10, Vector(math.floor(time), 0, 0))

		if IsServer() then EmitSoundOnLocationForAllies(caster:GetOrigin(), "Ability.PowershotPull.Lyralei", caster) end
	end

	function genuine_5__awakening:StopEfxChannel()
		local caster = self:GetCaster()
		if self.effect_cast then ParticleManager:DestroyParticle(self.effect_cast, false) end

		if IsServer() then
			caster:StopSound("Ability.PowershotPull.Lyralei")
			caster:EmitSound("Ability.Powershot.Alt")
		end
	end