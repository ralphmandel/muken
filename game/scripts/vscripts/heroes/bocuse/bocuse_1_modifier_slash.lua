bocuse_1_modifier_slash = class({})

function bocuse_1_modifier_slash:IsHidden()
	return true
end

function bocuse_1_modifier_slash:IsPurgable()
	return false
end

function bocuse_1_modifier_slash:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_1_modifier_slash:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.interrupted = false

	self.chance = self.ability:GetSpecialValueFor("init_chance") + kv.bonus_chance
	self.cut_intervals = self.ability:GetSpecialValueFor("cut_intervals")
	self.stun_duration = self.ability:GetSpecialValueFor("stun_duration")
	self.total_stun = self.stun_duration
	
	self.cut_direction = {
		[1] = Vector(90, 0, 180),
		[2] = Vector(0, 0, 200),
		[3] = Vector(0, 180, 330),
		[4] = Vector(90, 0, 225),
		[5] = Vector(90, 0, 135)
	}

	self.parent:AttackNoEarlierThan(10, 20)
	self:PrepareSlash(self.ability.target)
end

function bocuse_1_modifier_slash:OnRefresh(kv)
end

function bocuse_1_modifier_slash:OnRemoved()
	self.parent:AttackNoEarlierThan(1, 1)
	if self.interrupted then self.parent:FadeGesture(ACT_DOTA_ATTACK) end

	if self.ability.target then
		if IsValidEntity(self.ability.target) then
			self.parent:MoveToTargetToAttack(self.ability.target)	
		end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_1_modifier_slash:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_DISABLE_TURNING,
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_EVENT_ON_STATE_CHANGED
	}

	return funcs
end

function bocuse_1_modifier_slash:GetModifierMoveSpeed_Limit()
	return 250
end

function bocuse_1_modifier_slash:GetModifierDisableTurning()
	return 1
end

function bocuse_1_modifier_slash:OnOrder(keys)
	if keys.unit ~= self.parent then return end
	if keys.order_type > 4 and keys.order_type < 9 then
		self.interrupted = true
		self:Destroy()
	end
end

function bocuse_1_modifier_slash:OnStateChanged(keys)
	if keys.unit ~= self.parent then return end

	-- UP 1.31
	if (self.ability:GetRank(31) == false and self.parent:IsDisarmed())
	or self.parent:IsStunned() or self.parent:IsHexed()
	or self.parent:IsFrozen() then
		self.interrupted = true
		self:Destroy()
	end
end

function bocuse_1_modifier_slash:OnIntervalThink()
	self:PrepareSlash(self.ability.target)
end

-- UTILS -----------------------------------------------------------

function bocuse_1_modifier_slash:PrepareSlash(target)
	if IsServer() then 
		if self:IsValidTarget(target) then
			local vector = (target:GetAbsOrigin() - self.parent:GetAbsOrigin()):Normalized()
			self.parent:SetForwardVector(vector)

			local enemies = FindUnitsInRadius(
				self.caster:GetTeamNumber(), target:GetOrigin(), nil, self.ability:GetAOERadius(),
				self.ability:GetAbilityTargetTeam(), self.ability:GetAbilityTargetType(),
				self.ability:GetAbilityTargetFlags(), 0, false
			)

			for _,enemy in pairs(enemies) do
				self:ApplyCut(enemy)
			end

			if self:CalculateChance() then
				self:PrepareGesture(self.parent)
				self:StartIntervalThink(self.cut_intervals)
				return
			else
				for _,enemy in pairs(enemies) do
					self:ApplyStun(enemy)
				end
			end
		end

		self:StartIntervalThink(-1)
		self:Destroy()
	end
end

function bocuse_1_modifier_slash:PrepareGesture(caster)
	self.total_stun = self.total_stun + self.stun_duration

	Timers:CreateTimer(0.16, function()
		if caster then
			if IsValidEntity(caster) then
				if caster:HasModifier("bocuse_1_modifier_slash") then
					caster:FadeGesture(ACT_DOTA_ATTACK)
					caster:StartGestureWithPlaybackRate(ACT_DOTA_ATTACK, 5)
					if IsServer() then caster:EmitSound("Hero_Pudge.PreAttack") end
				end		
			end
		end
	end)
end

function bocuse_1_modifier_slash:IsValidTarget(target)
	if target == nil then return false end
	if IsValidEntity(target) == false then return false end

	local cast_range = self.ability:GetCastRange(self.parent:GetOrigin(), target)
	local max_distance = self.ability:GetSpecialValueFor("max_range") + cast_range
    local distance = CalcDistanceBetweenEntityOBB(self.parent, target)

	-- UP 1.11
	if self.ability:GetRank(11) == false
	and distance > max_distance then
		return false
	end

	-- UP 1.31
	if self.ability:GetRank(31) == false
	and target:IsInvisible() then
		return false
	end

	local target_result = UnitFilter(
		target, self.ability:GetAbilityTargetTeam(),
		self.ability:GetAbilityTargetType(),
		self.ability:GetAbilityTargetFlags(),
		self.caster:GetTeamNumber()
	)

	local caster_result = UnitFilter(
		self.parent, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO,
		DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_NIGHTMARED,
		self.caster:GetTeamNumber()
	)
	
	return (target_result == UF_SUCCESS) and (caster_result == UF_SUCCESS) 
end

function bocuse_1_modifier_slash:CalculateChance()
	self.chance = self.chance - 15
	return RandomFloat(1, 100) <= self.chance
end

function bocuse_1_modifier_slash:ApplyCut(target)
	ApplyDamage({
		victim = target, attacker = self.caster,
		damage = self.ability:GetAbilityDamage(),
		damage_type = self.ability:GetAbilityDamageType(),
		ability = self.ability
	})

	-- UP 1.22
	if self.ability:GetRank(22) then
		self:ApplyDisarm(target)
	end

	self.ability:ApplyBleeding(target)
	self:PlayEfxCut(target)
end

function bocuse_1_modifier_slash:ApplyDisarm(target)
	if target:IsAlive() == false or target:IsMagicImmune() then return end

	local chance = 10
	local base_stats = self.parent:FindAbilityByName("base_stats")
	if base_stats then chance = chance * base_stats:GetCriticalChance() end

	if RandomFloat(1, 100) <= chance then
		target:AddNewModifier(self.caster, self.ability, "_modifier_disarm", {
			duration = self.ability:CalcStatus(5, self.caster, target)
		})		
	end
end

function bocuse_1_modifier_slash:ApplyStun(target)
	if target:IsAlive() == false or target:IsMagicImmune() then return end
	
	target:AddNewModifier(self.caster, self.ability, "_modifier_stun", {
		duration = self.ability:CalcStatus(self.total_stun, self.caster, target)
	})
end

-- EFFECTS -----------------------------------------------------------

function bocuse_1_modifier_slash:PlayEfxCut(target)
	local point = target:GetOrigin()
	local forward = self.parent:GetForwardVector():Normalized()
	local point = point - (forward * 100)
	point.z = point.z + 100
	local direction = (point - self.parent:GetOrigin())

	local effect_cast = ParticleManager:CreateParticle("particles/bocuse/bocuse_strike_blur.vpcf", PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, point)
	ParticleManager:SetParticleControlForward(effect_cast, 0, direction:Normalized())
	ParticleManager:SetParticleControl(effect_cast, 10, self.cut_direction[RandomInt(1, 5)])
	ParticleManager:ReleaseParticleIndex(effect_cast)

	if IsServer() then target:EmitSound("Bocuse.Cut") end
end