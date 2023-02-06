bocuse_1__julienne = class({})
LinkLuaModifier("bocuse_1_modifier_passive", "heroes/bocuse/bocuse_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_1_modifier_julienne", "heroes/bocuse/bocuse_1_modifier_julienne", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_1_modifier_bleeding", "heroes/bocuse/bocuse_1_modifier_bleeding", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function bocuse_1__julienne:GetIntrinsicModifierName()
		return "bocuse_1_modifier_passive"
	end

  function bocuse_1__julienne:OnAbilityPhaseStart()
    local caster = self:GetCaster()

		if self:GetCastPoint() == 0.1 then return true end

		Timers:CreateTimer(0.25, function()
			if IsServer() then caster:EmitSound("Hero_Pudge.PreAttack") end
		end)

    return true
  end

  function bocuse_1__julienne:OnAbilityPhaseInterrupted()
    local caster = self:GetCaster()
    if IsServer() then caster:StopSound("Hero_Pudge.PreAttack") end
  end

  function bocuse_1__julienne:OnSpellStart()
    local caster = self:GetCaster()
		self.target = self:GetCursorTarget()
    caster:AddNewModifier(caster, self, "bocuse_1_modifier_julienne", {})
  end

  function bocuse_1__julienne:PerformSlash(slash_count)
		if self:CheckRequirements() == nil then return end

		local caster = self:GetCaster()
		local vector = (self.target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
		caster:SetForwardVector(vector)
		caster:FadeGesture(ACT_DOTA_ATTACK)
		caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 5)

		if IsServer() then caster:EmitSound("Hero_Pudge.PreAttack") end

		Timers:CreateTimer(0.1, function()
			if self:CheckRequirements() then
				if slash_count == 1 then
					self.target:AddNewModifier(caster, self, "_modifier_stun", {
						duration = CalcStatus(self:GetSpecialValueFor("stun_duration"), caster, self.target)
					})
				end

				caster:PerformAttack(self.target, false, true, true, false, false, false, true)
				self:PlayEfxCut(self.target)
			end
		end)
  end

	function bocuse_1__julienne:CheckRequirements()
		local caster = self:GetCaster()
		if self.target == nil then return end
		if IsValidEntity(self.target) == false then return end
		if caster:HasModifier("bocuse_1_modifier_julienne") == false then return end

		local max_range = self:GetCastRange(caster:GetOrigin(), self.target) + self:GetSpecialValueFor("bonus_limit_range")
		if CalcDistanceBetweenEntityOBB(caster, self.target) > max_range
		or self.target:IsAlive() == false
		or self.target:IsInvulnerable()
		or self.target:IsOutOfGame() then
			caster:RemoveModifierByName("bocuse_1_modifier_julienne")
			return
		end

		return true
	end

	function bocuse_1__julienne:GetCastPoint()
		return self:GetSpecialValueFor("cast_point")
	end

-- EFFECTS

	function bocuse_1__julienne:PlayEfxCut(target)
		local caster = self:GetCaster()
		local point = target:GetOrigin()
		local forward = caster:GetForwardVector():Normalized()
		local point = point - (forward * 100)
		point.z = point.z + 100
		local direction = (point - caster:GetOrigin())

		local cut_direction = {
			[1] = Vector(90, 0, 180),
			[2] = Vector(0, 0, 200),
			[3] = Vector(0, 180, 330),
			[4] = Vector(90, 0, 225),
			[5] = Vector(90, 0, 135)
		}

		local effect_cast = ParticleManager:CreateParticle("particles/bocuse/bocuse_strike_blur.vpcf", PATTACH_ABSORIGIN, caster)
		ParticleManager:SetParticleControl(effect_cast, 0, point)
		ParticleManager:SetParticleControlForward(effect_cast, 0, direction:Normalized())
		ParticleManager:SetParticleControl(effect_cast, 10, cut_direction[RandomInt(1, 5)])
		ParticleManager:ReleaseParticleIndex(effect_cast)

		if IsServer() then target:EmitSound("Bocuse.Cut") end
	end