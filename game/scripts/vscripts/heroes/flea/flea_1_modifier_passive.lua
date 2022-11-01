flea_1_modifier_passive = class({})

function flea_1_modifier_passive:IsHidden()
	return false
end

function flea_1_modifier_passive:IsPurgable()
	return false
end

function flea_1_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_1_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:ResetCharges() end
end

function flea_1_modifier_passive:OnRefresh(kv)
end

function flea_1_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_1_modifier_passive:OnIntervalThink()
	self:ResetCharges()
	self:StartIntervalThink(-1)
end

function flea_1_modifier_passive:OnStackCountChanged(old)
	local charges = self.ability:GetSpecialValueFor("charges")
	local refresh = self.ability:GetSpecialValueFor("refresh")

	if self:GetStackCount() == 0 then
		self.ability:StartCooldown(refresh)
		self:StartIntervalThink(-1)
		self:ResetCharges()
		return
	end

	if self:GetStackCount() < charges then
		self.ability:StartCooldown(0.8)
		self:StartIntervalThink(refresh)
	end
end

-- UTILS -----------------------------------------------------------

function flea_1_modifier_passive:ResetCharges()
	local charges = self.ability:GetSpecialValueFor("charges")
	self:SetStackCount(charges)
end

-- EFFECTS -----------------------------------------------------------