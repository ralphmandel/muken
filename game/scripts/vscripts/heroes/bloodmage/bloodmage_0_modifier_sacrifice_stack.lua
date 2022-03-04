bloodmage_0_modifier_sacrifice_stack = class({})
local tempTable = require("libraries/tempTable")

function bloodmage_0_modifier_sacrifice_stack:IsPurgable()
	return false
end

function bloodmage_0_modifier_sacrifice_stack:IsHidden()
	return true
end

function bloodmage_0_modifier_sacrifice_stack:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function bloodmage_0_modifier_sacrifice_stack:OnCreated( kv )
	if IsServer() then
		-- get references
		self.modifier = tempTable:RetATValue( kv.modifier )
	end
end

function bloodmage_0_modifier_sacrifice_stack:OnRemoved()
	if IsServer() then
		-- decrement stack
		if not self.modifier:IsNull() then
			self.modifier:DecrementStackCount()
		end
	end
end

function bloodmage_0_modifier_sacrifice_stack:OnDestroy()
end