druid_2_modifier_passive = class({})

function druid_2_modifier_passive:IsHidden() return false end
function druid_2_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_2_modifier_passive:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	if IsServer() then self:ResetCharges() end
end

function druid_2_modifier_passive:OnRefresh(kv)
end

function druid_2_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_2_modifier_passive:OnIntervalThink()
	self:ResetCharges()
	self:StartIntervalThink(-1)
end

function druid_2_modifier_passive:OnStackCountChanged(old)
	local charges = self.ability:GetSpecialValueFor("special_charges")
	local cd = self.ability:GetCooldown(self.ability:GetLevel())

	if self:GetStackCount() == 0 then
		self.ability:StartCooldown(cd)
		self:StartIntervalThink(-1)
		self:ResetCharges()
		return
	end

	if self:GetStackCount() < charges then
		self.ability:EndCooldown()
		self:StartIntervalThink(cd)
	end
end

-- UTILS -----------------------------------------------------------

function druid_2_modifier_passive:ResetCharges()
	local charges = self.ability:GetSpecialValueFor("special_charges")

	self:SetStackCount(charges)
end

-- EFFECTS -----------------------------------------------------------