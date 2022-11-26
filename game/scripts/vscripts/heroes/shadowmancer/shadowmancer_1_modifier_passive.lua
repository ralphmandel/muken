shadowmancer_1_modifier_passive = class({})

function shadowmancer_1_modifier_passive:IsHidden()
	return false
end

function shadowmancer_1_modifier_passive:IsPurgable()
	return false
end

function shadowmancer_1_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function shadowmancer_1_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:ResetCharges() end
end

function shadowmancer_1_modifier_passive:OnRefresh(kv)
end

function shadowmancer_1_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function shadowmancer_1_modifier_passive:OnIntervalThink()
	self:ResetCharges()
	self:StartIntervalThink(-1)
end

function shadowmancer_1_modifier_passive:OnStackCountChanged(old)
	local charges = self.ability:GetSpecialValueFor("charges")
	local refresh = self.ability:GetSpecialValueFor("refresh")

	-- UP 1.41
	-- if self.ability:GetRank(41) then
	-- 	charges = charges + 1
	-- end

	if self:GetStackCount() == 0 then
		self.ability:StartCooldown(refresh)
		self:StartIntervalThink(-1)
		self:ResetCharges()
		return
	end

	if self:GetStackCount() < charges then
		self.ability:StartCooldown(1)
		self:StartIntervalThink(refresh)
	end
end

-- UTILS -----------------------------------------------------------

function shadowmancer_1_modifier_passive:ResetCharges()
	local charges = self.ability:GetSpecialValueFor("charges")

	-- UP 1.41
	-- if self.ability:GetRank(41) then
	-- 	charges = charges + 1
	-- end

	self:SetStackCount(charges)
end

-- EFFECTS -----------------------------------------------------------

function shadowmancer_1_modifier_passive:GetEffectName()
	return "particles/shadowmancer/shadowmancer_arcana_ambient.vpcf"
end

function shadowmancer_1_modifier_passive:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end