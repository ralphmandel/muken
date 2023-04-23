flea_3_modifier_passive = class({})

function flea_3_modifier_passive:IsHidden() return false end
function flea_3_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_3_modifier_passive:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	if IsServer() then self:ResetCharges() end
end

function flea_3_modifier_passive:OnRefresh(kv)
end

function flea_3_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_3_modifier_passive:OnIntervalThink()
	self:ResetCharges()
	self:StartIntervalThink(-1)
end

function flea_3_modifier_passive:OnStackCountChanged(old)
	local charges = self.ability:GetSpecialValueFor("special_charges")
	local cooldown = self.ability:GetEffectiveCooldown(self.ability:GetLevel())

	if self:GetStackCount() == 0 then
		self.ability:EndCooldown()
		self.ability:StartCooldown(cooldown)
		self:StartIntervalThink(-1)
		self:ResetCharges()
		return
	end

	if self:GetStackCount() < charges then
		self.ability:EndCooldown()
		self.ability:StartCooldown(0.8)
		self:StartIntervalThink(cooldown)
	end
end

-- UTILS -----------------------------------------------------------

function flea_3_modifier_passive:ResetCharges()
	local charges = self.ability:GetSpecialValueFor("special_charges")

	self:SetStackCount(charges)
end

-- EFFECTS -----------------------------------------------------------