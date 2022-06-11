_1_INT_modifier_stack = class({})

function _1_INT_modifier_stack:IsPurgable()
	return false
end

function _1_INT_modifier_stack:IsHidden()
	return true
end

function _1_INT_modifier_stack:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _1_INT_modifier_stack:OnCreated( kv )
	if IsServer() then
		self.stacks = kv.stacks
		self.percent = kv.percent

		local base_stats = self:GetParent():FindAbilityByName("base_stats")
		if base_stats then base_stats:CalculateStats(self.stacks, self.percent, "INT") end
	end
end

function _1_INT_modifier_stack:OnRemoved()
	if IsServer() then
		local base_stats = self:GetParent():FindAbilityByName("base_stats")
		if base_stats then base_stats:CalculateStats(-self.stacks, -self.percent, "INT") end
	end
end

function _1_INT_modifier_stack:OnDestroy()
end