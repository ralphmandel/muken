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

    if BaseHeroMod(caster) then
      BaseHeroMod(caster):ChangeActivity("")
      caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 0.4)
    end

		Timers:CreateTimer(0.25, function()
			if IsServer() then caster:EmitSound("Hero_Pudge.PreAttack") end
		end)

    return true
  end

  function bocuse_1__julienne:OnAbilityPhaseInterrupted()
    local caster = self:GetCaster()

    if BaseHeroMod(caster) then
      BaseHeroMod(caster):ChangeActivity("trapper")
      caster:FadeGesture(ACT_DOTA_ATTACK)
    end

    if IsServer() then caster:StopSound("Hero_Pudge.PreAttack") end
  end

  function bocuse_1__julienne:OnSpellStart()
    local caster = self:GetCaster()
		self.target = self:GetCursorTarget()
    self.crit = self:GetSpecialValueFor("special_frenesi_chance") > 0

    if RandomFloat(1, 100) <= self:GetSpecialValueFor("special_frenesi_chance") then
      self.total_slashes = self:GetSpecialValueFor("special_max_cut")
      self.cut_speed = self:GetSpecialValueFor("special_cut_speed")
    else
      self.total_slashes = self:GetSpecialValueFor("max_cut")
      self.cut_speed = self:GetSpecialValueFor("cut_speed")
    end

    if BaseHeroMod(caster) then
      BaseHeroMod(caster):ChangeActivity("trapper")
      caster:FadeGesture(ACT_DOTA_ATTACK)
    end

    caster:AddNewModifier(caster, self, "bocuse_1_modifier_julienne", {})
  end

  function bocuse_1__julienne:PerformSlash(slash_count)
		if self:CheckRequirements() == nil then return end

		local caster = self:GetCaster()
		local vector = (self.target:GetAbsOrigin() - caster:GetAbsOrigin()):Normalized()
		caster:SetForwardVector(vector)
		caster:FadeGesture(ACT_DOTA_ATTACK)
		caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, self.cut_speed)

		if IsServer() then caster:EmitSound("Hero_Pudge.PreAttack") end

		Timers:CreateTimer(0.1, function()
			if self:CheckRequirements() then
        local never_miss = false
				if slash_count == 1 then
          never_miss = true
          self:ApplyStun(self.target)
				end

        if self.crit == true or slash_count == 1 then
          BaseStats(caster):SetForceCrit(100, nil)
        end

				caster:PerformAttack(self.target, false, true, true, false, false, false, never_miss)
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

  function bocuse_1__julienne:ApplyStun(target)
    local caster = self:GetCaster()
    local stun_radius = self:GetSpecialValueFor("special_stun_radius")

    if stun_radius > 0 then
      self:PlayEfxBlast(target, stun_radius)

      local enemies = FindUnitsInRadius(
        caster:GetTeamNumber(), target:GetOrigin(), nil, stun_radius,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
        DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false
      )
  
      for _,enemy in pairs(enemies) do
        enemy:AddNewModifier(caster, self, "_modifier_stun", {
          duration = CalcStatus(self:GetSpecialValueFor("stun_duration"), caster, enemy)
        })
      end
    else
      if target:IsMagicImmune() == false then
        target:AddNewModifier(caster, self, "_modifier_stun", {
          duration = CalcStatus(self:GetSpecialValueFor("stun_duration"), caster, target)
        })
      end
    end
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

  function bocuse_1__julienne:PlayEfxBlast(target, radius)
    local string = "particles/econ/items/techies/techies_arcana/techies_remote_mines_detonate_arcana.vpcf"
    local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, target)
    ParticleManager:SetParticleControl(particle, 0, target:GetOrigin())
    ParticleManager:SetParticleControl(particle, 1, Vector(radius, radius, radius))
    ParticleManager:ReleaseParticleIndex(particle)

    local string_2 = "particles/osiris/poison_alt/osiris_poison_splash_shake.vpcf"
    local shake = ParticleManager:CreateParticle(string_2, PATTACH_ABSORIGIN, target)
    ParticleManager:SetParticleControl(shake, 0, target:GetOrigin())
    ParticleManager:SetParticleControl(shake, 1, Vector(400, 0, 0))
  
    if IsServer() then target:EmitSound("Hero_Sven.StormBoltImpact") end
  end