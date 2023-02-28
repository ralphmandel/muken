genuine_5_modifier_passive = class({})

function genuine_5_modifier_passive:IsHidden() return false end
function genuine_5_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_5_modifier_passive:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	if IsServer() then self:ResetCharges() end
end

function genuine_5_modifier_passive:OnRefresh(kv)
end

function genuine_5_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_5_modifier_passive:OnIntervalThink()
	self:ResetCharges()
	self:StartIntervalThink(-1)
end

function genuine_5_modifier_passive:OnStackCountChanged(old)
	local charges = self.ability:GetSpecialValueFor("charges")
	local cd = self.ability:GetCooldown(self.ability:GetLevel())

	if self:GetStackCount() == 0 then
		self.ability:StartCooldown(cd)
		self:StartIntervalThink(-1)
		self:ResetCharges()
		return
	end

	if self:GetStackCount() < charges then
		self.ability:EndCooldown()
		self.ability:StartCooldown(0.8)
		self:StartIntervalThink(cd)
	end
end

-- UTILS -----------------------------------------------------------

function genuine_5_modifier_passive:ResetCharges()
	local charges = self.ability:GetSpecialValueFor("charges")

	self:SetStackCount(charges)
end

-- EFFECTS -----------------------------------------------------------