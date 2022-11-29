bald_2_modifier_heap = class({})

function bald_2_modifier_heap:IsHidden()
	return true
end

function bald_2_modifier_heap:IsPurgable()
	return false
end

function bald_2_modifier_heap:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_2_modifier_heap:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.time = self:GetDuration()
	self.dash = false

	self.parent:AddNewModifier(self.caster, self.ability, "bald_2_modifier_gesture", {})

	if IsServer() then
		self:OnIntervalThink()
		self.parent:EmitSound("Hero_Spirit_Breaker.Magnet.Cast")
	end
end

function bald_2_modifier_heap:OnRefresh(kv)
end

function bald_2_modifier_heap:OnRemoved()
	local stun_max = self.ability:GetSpecialValueFor("stun_max")
	local damage_max = self.ability:GetSpecialValueFor("damage_max")
	local elapsed_time = self:GetDuration() - self.time

	self.ability.damage = (damage_max * elapsed_time) / self:GetDuration()
	self.ability.stun = (stun_max * elapsed_time) / self:GetDuration()
	self.ability.spin_range = 0
	self.ability:CheckAbilityCharges(1)

	self.parent:RemoveModifierByName("bald_2_modifier_gesture")

	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	if self.dash == false then
		self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
	end
	
	if IsServer() then self.parent:StopSound("Hero_Spirit_Breaker.Magnet.Cast") end
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_2_modifier_heap:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true
	}

	return state
end

function bald_2_modifier_heap:OnIntervalThink()
	self:PlayEfxTimer()

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
		duration = 0.5,
		percent = (self:GetElapsedTime() * 12)
	})
	
	local tick = 0.5
	if self.time <= tick + 0.1 then tick = -1 end
	self.time = self.time - tick
	self.ability.spin_range = self.ability.spin_range + 1
	self.ability:CheckAbilityCharges(1)

	if IsServer() then self:StartIntervalThink(tick) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bald_2_modifier_heap:PlayEfxTimer()
	local particle_cast = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_timer.vpcf"

	local time = math.floor(self.time)
	local mid = 1
	if self.time - time > 0 then mid = 8 end

	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(1, time, mid))
	ParticleManager:SetParticleControl(effect_cast, 2, Vector(2, 0, 0))

	if time < 1 then
		ParticleManager:SetParticleControl(effect_cast, 2, Vector( 1, 0, 0 ))
	end

	ParticleManager:ReleaseParticleIndex(effect_cast)
end