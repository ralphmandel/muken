bald_2_modifier_heap = class({})

function bald_2_modifier_heap:IsHidden() return true end
function bald_2_modifier_heap:IsPurgable() return false end
function bald_2_modifier_heap:GetPriority() return MODIFIER_PRIORITY_ULTRA end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_2_modifier_heap:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.parent:AddNewModifier(self.caster, self.ability, "bald_2_modifier_gesture", {})
	self.max_charge = self.ability:GetSpecialValueFor("max_charge")
	self.time = self.max_charge
	self.tick = 0.31

	local base_stats = self.parent:FindAbilityByName("base_stats")
	if base_stats then base_stats:SetMPRegenState(-1) end

	local bonus_ms = self.ability:GetSpecialValueFor("bonus_ms")
	if bonus_ms > 0 then
		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {
			percent = bonus_ms
		})
	end

	if IsServer() then
		self:StartIntervalThink(0.1)
		self.ability.dash = true
	end
end

function bald_2_modifier_heap:OnRefresh(kv)
end

function bald_2_modifier_heap:OnRemoved()
	self.ability.dash = false

	local stun_max = self.ability:GetSpecialValueFor("stun_max")
	local damage_max = self.ability:GetSpecialValueFor("damage_max")
	local elapsed_time = self:GetElapsedTime()

	self.ability.damage = (damage_max * elapsed_time) / self.max_charge
	self.ability.stun = (stun_max * elapsed_time) / self.max_charge

	self.parent:RemoveModifierByName("bald_2_modifier_gesture")
	local base_stats = self.parent:FindAbilityByName("base_stats")
	if base_stats then base_stats:SetMPRegenState(1) end

	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_debuff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end

	local mod = self.parent:FindAllModifiersByName("_modifier_movespeed_buff")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
	
	if IsServer() then self.parent:StopSound("Hero_Spirit_Breaker.Magnet.Cast") end
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_2_modifier_heap:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true
	}

	if self:GetAbility():GetSpecialValueFor("stun_immunity") == 1 then
		table.insert(state, MODIFIER_STATE_STUNNED, false)
	end

	return state
end

function bald_2_modifier_heap:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ABILITY_START
	}

	return funcs
end

function bald_2_modifier_heap:OnAbilityStart(keys)
	if keys.unit == self.parent then
		if keys.ability ~= self.ability then
			self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
			self:Destroy()
		end
	end
end

function bald_2_modifier_heap:OnIntervalThink()
	if self.time == 0 then
		self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
		self:Destroy()
		return
	end

	if IsServer() then
		if self.time == self.max_charge then
			self.parent:EmitSound("Hero_Spirit_Breaker.Magnet.Cast")
		end
	end

	local tick = 0.5
	self:PlayEfxTimer()
	self.time = self.time - tick

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {
		duration = self.tick,
		percent = (self:GetElapsedTime() * (75 / self.max_charge))
	})

	if IsServer() then
		self:StartIntervalThink(self.tick)
		self.tick = self.tick * 1.03
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bald_2_modifier_heap:PlayEfxTimer()
	local particle_cast = "particles/units/heroes/hero_alchemist/alchemist_unstable_concoction_timer.vpcf"

	local time = math.floor(self.time)
	local mid = 1
	if self.time - time > 0 then mid = 8 end

	if self.efx_count then ParticleManager:DestroyParticle(self.efx_count, true) end
	self.efx_count = ParticleManager:CreateParticle(particle_cast, PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.efx_count, 1, Vector(1, time, mid))
	ParticleManager:SetParticleControl(self.efx_count, 2, Vector(2, 0, 0))

	if time < 1 then
		ParticleManager:SetParticleControl(self.efx_count, 2, Vector( 1, 0, 0 ))
	end
end