rage_modifier_damage_stack = class({})
local tempTable = require("libraries/tempTable")

function rage_modifier_damage_stack:IsPurgable()
	return false
end

function rage_modifier_damage_stack:IsHidden()
	return true
end

function rage_modifier_damage_stack:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function rage_modifier_damage_stack:OnCreated( kv )
	if IsServer() then
		-- get references
		self.modifier = tempTable:RetATValue( kv.modifier )
	end
end

function rage_modifier_damage_stack:OnRemoved()
	if IsServer() then
		-- decrement stack
		if not self.modifier:IsNull() then
			self.modifier:DecrementStackCount()
		end
	end
end

function rage_modifier_damage_stack:OnDestroy()
end