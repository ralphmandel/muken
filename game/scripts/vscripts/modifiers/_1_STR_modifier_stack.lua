_1_STR_modifier_stack = class({})

function _1_STR_modifier_stack:IsPurgable()
	return false
end

function _1_STR_modifier_stack:IsHidden()
	return true
end

function _1_STR_modifier_stack:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _1_STR_modifier_stack:OnCreated( kv )
	if IsServer() then
		self.stacks = kv.stacks
		self.percent = kv.percent

		BaseStats(self:GetParent()):CalculateStats(self.stacks, self.percent, "STR")
	end
end

function _1_STR_modifier_stack:OnRemoved()
	if IsServer() then
		BaseStats(self:GetParent()):CalculateStats(-self.stacks, -self.percent, "STR")
	end
end

function _1_STR_modifier_stack:OnDestroy()
end