example_5_modifier_charges = class({})

function example_5_modifier_charges:IsHidden() return false end
function example_5_modifier_charges:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function example_5_modifier_charges:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	if IsServer() then self:ResetCharges() end
end

function example_5_modifier_charges:OnRefresh(kv)
end

function example_5_modifier_charges:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function example_5_modifier_charges:OnIntervalThink()
	self:ResetCharges()
	self:StartIntervalThink(-1)
end

function example_5_modifier_charges:OnStackCountChanged(old)
	if self:GetStackCount() == 0 then
		self:StartIntervalThink(-1)
		self:ResetCharges()
		return
	end

	if self:GetStackCount() < self.ability:GetSpecialValueFor("charges") then
		self.ability:EndCooldown()
		self:StartIntervalThink(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
	end
end

-- UTILS -----------------------------------------------------------

function example_5_modifier_charges:ResetCharges()
	self:SetStackCount(self.ability:GetSpecialValueFor("charges"))
end

-- EFFECTS -----------------------------------------------------------