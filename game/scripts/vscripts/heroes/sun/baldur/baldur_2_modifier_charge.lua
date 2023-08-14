baldur_2_modifier_charge = class({})

function baldur_2_modifier_charge:IsHidden() return true end
function baldur_2_modifier_charge:IsPurgable() return false end
function baldur_2_modifier_charge:GetPriority() return MODIFIER_PRIORITY_ULTRA end

-- CONSTRUCTORS -----------------------------------------------------------

function baldur_2_modifier_charge:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  
	self.gesture_time = self.ability:GetSpecialValueFor("gesture_time")
	self.gesture_mult = self.ability:GetSpecialValueFor("gesture_mult")
	self.max_charge = self.ability:GetSpecialValueFor("max_charge")
	self.time = self.max_charge

  AddModifier(self.parent, self.ability, "baldur_2_modifier_gesture", {}, false)
  AddModifier(self.parent, self.ability, "_modifier_percent_movespeed_debuff", {
    percent = self.ability:GetSpecialValueFor("slow_percent")
  }, false)

	if IsServer() then self:StartIntervalThink(0.1) end
end

function baldur_2_modifier_charge:OnRefresh(kv)
end

function baldur_2_modifier_charge:OnRemoved()
	self.parent:RemoveModifierByName("bald_2_modifier_gesture")
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_percent_movespeed_debuff", self.ability)

	if IsServer() then self.parent:StopSound("Bald.Dash.Cast") end
end

-- API FUNCTIONS -----------------------------------------------------------

function baldur_2_modifier_charge:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true
	}

	return state
end

function baldur_2_modifier_charge:DeclareFunctions()
	local funcs = {
    MODIFIER_EVENT_ON_STATE_CHANGED,
		MODIFIER_EVENT_ON_ABILITY_START
	}

	return funcs
end

function baldur_2_modifier_charge:OnStateChanged(keys)
  if keys.unit ~= self.parent then return end
  if self.parent:IsStunned() or self.parent:IsHexed() then
    self:EndCharge(true)
  end
end

function baldur_2_modifier_charge:OnAbilityStart(keys)
	if keys.unit == self.parent then
		if keys.ability ~= self.ability then
      self:EndCharge(true)
		end
	end
end

function baldur_2_modifier_charge:OnIntervalThink()
	if self.time == 0 then
    self:EndCharge(true)
		return
	end

  if self.time == self.max_charge then
    if IsServer() then self.parent:EmitSound("Bald.Dash.Cast") end
  end

  self:PlayEfxTimer()

	local tick = 0.5
	self.time = self.time - tick

	if IsServer() then
		self:StartIntervalThink(self.self.gesture_time)
		self.self.gesture_time = self.self.gesture_time * self.gesture_mult
	end
end

-- UTILS -----------------------------------------------------------

function baldur_2_modifier_charge:EndCharge(bInterrupt)
  self.ability:SetCurrentAbilityCharges(BALDUR_READY)
  self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
  self:Destroy()
end

-- EFFECTS -----------------------------------------------------------

function baldur_2_modifier_charge:PlayEfxTimer()
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