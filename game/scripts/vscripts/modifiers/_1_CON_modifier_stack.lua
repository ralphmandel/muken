_1_CON_modifier_stack = class({})

function _1_CON_modifier_stack:IsPurgable()
	return false
end

function _1_CON_modifier_stack:IsHidden()
	return true
end

function _1_CON_modifier_stack:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _1_CON_modifier_stack:OnCreated( kv )
	if IsServer() then
		self.stacks = kv.stacks
		self.percent = kv.percent

		local ability = self:GetParent():FindAbilityByName("_1_CON")
		if ability then
			if ability:IsTrained() then
				ability:CalculateAttributes(self.stacks, self.percent)
			end
		end
	end
end

function _1_CON_modifier_stack:OnRemoved()
	if IsServer() then
		local ability = self:GetParent():FindAbilityByName("_1_CON")
		if ability then
			if ability:IsTrained() then
				ability:CalculateAttributes(-self.stacks, -self.percent)
			end
		end
	end
end

function _1_CON_modifier_stack:OnDestroy()
end