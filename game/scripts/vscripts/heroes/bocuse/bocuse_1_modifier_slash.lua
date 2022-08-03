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
	self.target = nil

	self.stun_duration = self:GetSpecialValueFor("stun_duration")
	self.cut_intervals = self.ability:GetSpecialValueFor("cut_intervals")
	self.chance = self.ability:GetSpecialValueFor("init_chance") + kv.bonus_chance
	self.parent:AttackNoEarlierThan(10, 20)

	self.cut_direction = {
		[1] = Vector(90, 0, 180),
		[2] = Vector(0, 0, 200),
		[3] = Vector(0, 180, 330),
		[4] = Vector(90, 0, 225),
		[5] = Vector(90, 0, 135)
	}

	if IsServer() then
		self.total_stun = self.stun_duration
		self:StartIntervalThink(0.1)
	end
end

function bocuse_1_modifier_slash:OnRefresh(kv)
end

function bocuse_1_modifier_slash:OnRemoved()
	self.parent:AttackNoEarlierThan(1, 1)
end

-- API FUNCTIONS -----------------------------------------------------------

function _modifier_example:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_STATE_CHANGED
	}

	return funcs
end

function _modifier_example:OnStateChanged(keys)
	if keys.unit ~= self.parent then return end
	if self.parent:IsStunned() or self.parent:IsDisarmed()
	or self.parent:IsHexed() or self.parent:IsFrozen() then
		self:Destroy()
	end
end

function bocuse_1_modifier_slash:OnIntervalThink()
	if IsServer() then 
		if self:IsValidTarget(self.target) then
			self:ApplyCut(self.target)

			if self:CalculateChance() then
				self.total_stun = self.total_stun + self.stun_duration
				self:StartIntervalThink(self.cut_intervals)
				return
			else
				self:ApplyStun(self.target)
			end
		end

		self:StartIntervalThink(-1)
		self:Destroy()
	end
end

-- UTILS -----------------------------------------------------------

function bocuse_1_modifier_slash:IsValidTarget(target)
	if target == nil then return false end
	if IsValidEntity(target) == false then return false end

	local cast_range = self.ability:GetCastRange(self.parent:GetOrigin(), target)
	local max_distance = self.ability:GetSpecialValueFor("max_range") + cast_range
    local distance = CalcDistanceBetweenEntityOBB(self.parent, target)
	if distance > max_distance then return false end

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
	local bleeding_duration = self.ability:GetSpecialValueFor("bleeding_duration")

	ApplyDamage({
		victim = target, attacker = self.caster,
		damage = self:GetAbilityDamage(),
		damage_type = self:GetAbilityDamageType(),
		ability = self.ability
	})

	self:PlayEfxCut(target)

	if target:IsAlive() then
		target:AddNewModifier(self.caster, self.ability, "bocuse_1_modifier_bleeding", {
			duration = self.ability:CalcStatus(bleeding_duration, self.caster, target)
		})
	end
end

function bocuse_1_modifier_slash:ApplyStun(target)
	if target:IsAlive() == false or target:IsMagicImmune() then return end
	
	target:AddNewModifier(self.caster, self.ability, "_modifier_stun", {
		self.ability:CalcStatus(self.total_stun, self.caster, target)
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