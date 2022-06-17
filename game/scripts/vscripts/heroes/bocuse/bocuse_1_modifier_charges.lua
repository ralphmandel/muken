bocuse_1_modifier_charges = class({})

function bocuse_1_modifier_charges:IsHidden()
	return false
end

function bocuse_1_modifier_charges:IsPurgable()
    return false
end

function bocuse_1_modifier_charges:GetTexture()
	return "bocuse_charges"
end

--------------------------------------------------------------------------------

function bocuse_1_modifier_charges:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	if IsServer() then
		self.charges = self.ability:GetSpecialValueFor("charges")
		self:SetStackCount(self.charges)
	end
end

function bocuse_1_modifier_charges:OnRefresh( kv )
end

function bocuse_1_modifier_charges:OnRemoved()
end

--------------------------------------------------------------------------------

function bocuse_1_modifier_charges:OnStackCountChanged(old)
	if self:GetStackCount() > self.charges then self:SetStackCount(self.charges) return end
	if self:GetStackCount() < 0 then self:SetStackCount(0) return end
	if self:GetStackCount() < self.charges then self.ability:CheckCharges(false) end

	self.ability:ChangeManaCost()
	self.ability:SetActivated(self:GetStackCount() > 0)
end