bocuse_1_modifier_charges_stack = class({})

function bocuse_1_modifier_charges_stack:IsHidden()
	return false
end

function bocuse_1_modifier_charges_stack:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function bocuse_1_modifier_charges_stack:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
end

function bocuse_1_modifier_charges_stack:OnRefresh( kv )
end

function bocuse_1_modifier_charges_stack:OnRemoved()
	self.ability:CheckCharges(true)
end