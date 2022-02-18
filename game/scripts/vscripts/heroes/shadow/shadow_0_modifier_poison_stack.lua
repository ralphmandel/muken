shadow_0_modifier_poison_stack = class({})
local tempTable = require("libraries/tempTable")

function shadow_0_modifier_poison_stack:IsPurgable()
	return false
end

function shadow_0_modifier_poison_stack:IsHidden()
	return true
end

function shadow_0_modifier_poison_stack:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function shadow_0_modifier_poison_stack:OnCreated( kv )
	if IsServer() then
		-- get references
		self.modifier = tempTable:RetATValue( kv.modifier )
	end
end

function shadow_0_modifier_poison_stack:OnRemoved()
	if IsServer() then
		-- decrement stack
		if not self.modifier:IsNull() then
			self.modifier:DecrementStackCount()
		end
	end
end

function shadow_0_modifier_poison_stack:OnDestroy()
end