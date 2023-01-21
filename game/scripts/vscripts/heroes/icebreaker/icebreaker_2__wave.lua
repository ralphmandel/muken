icebreaker_2__wave = class({})
LinkLuaModifier("icebreaker_2_modifier_refresh", "heroes/icebreaker/icebreaker_2_modifier_refresh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker_2_modifier_path", "heroes/icebreaker/icebreaker_2_modifier_path", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo", "heroes/icebreaker/icebreaker__modifier_hypo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen", "heroes/icebreaker/icebreaker__modifier_frozen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_hypo_status_efx", "heroes/icebreaker/icebreaker__modifier_hypo_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("icebreaker__modifier_frozen_status_efx", "heroes/icebreaker/icebreaker__modifier_frozen_status_efx", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_silence", "modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_path", "modifiers/_modifier_path", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_phase", "modifiers/_modifier_phase", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function icebreaker_2__wave:OnOwnerSpawned()
		self:SetActivated(true)
	end

  function icebreaker_2__wave:OnSpellStart()
    local caster = self:GetCaster()
		local point = self:GetCursorPosition()
		local direction = (point - caster:GetAbsOrigin()):Normalized()
		local path_lifetime = self:GetSpecialValueFor("special_path_lifetime")
		self.first_hit = false

		caster:AddNewModifier(caster, self, "icebreaker_2_modifier_refresh", {})

		if IsServer() then caster:EmitSound("Hero_Ancient_Apparition.IceBlast.Target") end
		
		ProjectileManager:CreateLinearProjectile({
			Ability = self,
			EffectName = "particles/units/heroes/hero_drow/drow_silence_wave.vpcf",
			vSpawnOrigin = caster:GetAbsOrigin(),
			Source = caster,
			bHasFrontalCone = true,
			bReplaceExisting = false,
			fStartRadius = self:GetSpecialValueFor("radius"),
			fEndRadius = self:GetSpecialValueFor("radius"),
			fDistance = self:GetSpecialValueFor("distance"),
			iUnitTargetTeam = self:GetAbilityTargetTeam(),
			iUnitTargetFlags = self:GetAbilityTargetFlags(),
			iUnitTargetType = self:GetAbilityTargetType(),
			fExpireTime = GameRules:GetGameTime() + 10.0,
			bDeleteOnHit = false,
			vVelocity = direction * self:GetSpecialValueFor("speed"),
			bProvidesVision = true,
			iVisionRadius = self:GetSpecialValueFor("radius"),
			iVisionTeamNumber = caster:GetTeamNumber()
		})

		self.knockbackProperties = {
			center_x = caster:GetAbsOrigin().x + 1,
			center_y = caster:GetAbsOrigin().y + 1,
			center_z = caster:GetAbsOrigin().z,
			knockback_height = 0
		}

		if path_lifetime > 0 then
			CreateModifierThinker(caster, self, "icebreaker_2_modifier_path",{
				x = direction.x, y = direction.y, lifetime = path_lifetime
			}, caster:GetAbsOrigin(), caster:GetTeamNumber(), false)
		end
  end

	function icebreaker_2__wave:OnProjectileHit(target, vLocation)
		if target == nil then return end
		if target:HasModifier("icebreaker__modifier_frozen") then return end
		if IsServer() then target:EmitSound("Hero_Lich.preAttack") end

		local caster = self:GetCaster()
		local silence_duration = self:GetSpecialValueFor("special_silence_duration")
		local damage_percent = self:GetSpecialValueFor("special_damage_percent")
		local knockback = self:GetSpecialValueFor("special_knockback")

		self:CreateMirror(target)

		if silence_duration > 0 then
			target:AddNewModifier(caster, self, "_modifier_silence", {
				duration = CalcStatus(silence_duration, caster, target)
			})
		end

		if damage_percent > 0 then
			ApplyDamage({
				attacker = caster, victim = target,
				damage = target:GetMaxHealth() * damage_percent * 0.01,
				damage_type = DAMAGE_TYPE_MAGICAL, ability = self
			})
		end

		if knockback == 1 then
			local distance = self:GetSpecialValueFor("distance") + 500 - CalcDistanceBetweenEntityOBB(caster, target)
			self.knockbackProperties.duration = CalcStatus(distance / 5000, caster, target)
			self.knockbackProperties.knockback_duration = CalcStatus(distance / 5000, caster, target)
			self.knockbackProperties.knockback_distance = CalcStatus(distance / 6, caster, target)
			target:AddNewModifier(caster, nil, "modifier_knockback", self.knockbackProperties)
		end

		target:AddNewModifier(caster, self, "icebreaker__modifier_hypo", {
			duration = CalcStatus(self:GetSpecialValueFor("stack_duration"), caster, target),
			stack = RandomInt(self:GetSpecialValueFor("stack_min"), self:GetSpecialValueFor("stack_max"))
		})

		if self.first_hit == false then
			caster:MoveToTargetToAttack(target)
			self.first_hit = true
		end
	end

	function icebreaker_2__wave:CreateMirror(target)
		local caster = self:GetCaster()
		local mirror_lifetime = self:GetSpecialValueFor("special_mirror_lifetime")
		if mirror_lifetime == 0 then return end

		local illu_array = CreateIllusions(caster, caster, {
			outgoing_damage = -50,
			incoming_damage = 1000,
			bounty_base = 0,
			bounty_growth = 0,
			duration = mirror_lifetime
		}, 1, 64, false, true)

		for _,illu in pairs(illu_array) do
			local loc = target:GetAbsOrigin() + RandomVector(130)
			--illu:AddNewModifier(caster, self, "_modifier_phase", {})
			illu:SetAbsOrigin(loc)
			illu:SetForwardVector((target:GetAbsOrigin() - loc):Normalized())
			illu:SetForceAttackTarget(target)
			FindClearSpaceForUnit(illu, loc, true)
		end		
	end

-- EFFECTS