flea_1_modifier_precision_stack = class({})
local tempTable = require("libraries/tempTable")

function flea_1_modifier_precision_stack:IsPurgable()
	return true
end

function flea_1_modifier_precision_stack:IsHidden()
	return true
end

function flea_1_modifier_precision_stack:IsDebuff()
	return false
end

function flea_1_modifier_precision_stack:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_1_modifier_precision_stack:OnCreated( kv )
	if IsServer() then
		self.modifier = tempTable:RetATValue( kv.modifier )
	end
end

function flea_1_modifier_precision_stack:OnRemoved()
	if IsServer() then
		if not self.modifier:IsNull() then
			self.modifier:DecrementStackCount()
		end
	end
end

function flea_1_modifier_precision_stack:OnDestroy()
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function flea_1_modifier_precision_stack:GetEffectName()
	return "particles/econ/items/slark/slark_barb_of_skadi/slark_regen_barb_of_skadi.vpcf"
end

function flea_1_modifier_precision_stack:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end