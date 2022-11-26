shadowmancer_1_modifier_debuff_stack = class({})
local tempTable = require("libraries/tempTable")

function shadowmancer_1_modifier_debuff_stack:IsPurgable()
	return true
end

function shadowmancer_1_modifier_debuff_stack:IsHidden()
	return true
end

function shadowmancer_1_modifier_debuff_stack:IsDebuff()
	return false
end

function shadowmancer_1_modifier_debuff_stack:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-- CONSTRUCTORS -----------------------------------------------------------

function shadowmancer_1_modifier_debuff_stack:OnCreated( kv )
	if IsServer() then
		self.modifier = tempTable:RetATValue( kv.modifier )
	end
end

function shadowmancer_1_modifier_debuff_stack:OnRemoved()
	if IsServer() then
		if not self.modifier:IsNull() then
			self.modifier:DecrementStackCount()
		end
	end
end

function shadowmancer_1_modifier_debuff_stack:OnDestroy()
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------