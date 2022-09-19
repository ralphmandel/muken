osiris_1_modifier_poison_stack = class({})
local tempTable = require("libraries/tempTable")

function osiris_1_modifier_poison_stack:IsPurgable()
	return false
end

function osiris_1_modifier_poison_stack:IsHidden()
	return true
end

function osiris_1_modifier_poison_stack:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function osiris_1_modifier_poison_stack:OnCreated(kv)
	if IsServer() then
		self.modifier = tempTable:RetATValue(kv.modifier)
	end
end

function osiris_1_modifier_poison_stack:OnRemoved()
	if IsServer() then
		if not self.modifier:IsNull() then
			self.modifier:DecrementStackCount()
		end
	end
end

function osiris_1_modifier_poison_stack:OnDestroy()
end