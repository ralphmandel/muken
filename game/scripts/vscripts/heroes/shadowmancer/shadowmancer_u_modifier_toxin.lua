shadowmancer_u_modifier_toxin = class({})

function shadowmancer_u_modifier_toxin:IsHidden()
	return false
end

function shadowmancer_u_modifier_toxin:IsPurgable()
	return false
end

function shadowmancer_u_modifier_toxin:IsDebuff()
	return true
end

function shadowmancer_u_modifier_toxin:GetTexture()
	return "toxin"
end

-- CONSTRUCTORS -----------------------------------------------------------

function shadowmancer_u_modifier_toxin:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local decay_delay = self.ability:GetSpecialValueFor("decay_delay")

	if IsServer() then
		self:SetStackCount(kv.amount)
		self:StartIntervalThink(decay_delay)
	end
end

function shadowmancer_u_modifier_toxin:OnRefresh(kv)
	local decay_delay = self.ability:GetSpecialValueFor("decay_delay")

	if IsServer() then
		self:SetStackCount(self:GetStackCount() + kv.amount)
		self:StartIntervalThink(decay_delay)
	end
end

function shadowmancer_u_modifier_toxin:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function shadowmancer_u_modifier_toxin:OnIntervalThink()
	local decay_tick = self.ability:GetSpecialValueFor("decay_tick")

	if IsServer() then
		self:DecrementStackCount()
		self:StartIntervalThink(decay_tick)
	end
end

function shadowmancer_u_modifier_toxin:OnStackCountChanged(old)
	if self:GetStackCount() == 0 then self:Destroy() end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------