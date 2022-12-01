bald_3_modifier_passive_stack = class({})
local tempTable = require("libraries/tempTable")

function bald_3_modifier_passive_stack:IsHidden() return true end
function bald_3_modifier_passive_stack:IsPurgable() return true end
function bald_3_modifier_passive_stack:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_3_modifier_passive_stack:OnCreated( kv )
	if IsServer() then
		self.modifier = tempTable:RetATValue( kv.modifier )
	end
end

function bald_3_modifier_passive_stack:OnRemoved()
	if IsServer() then
		if not self.modifier:IsNull() then
			self.modifier:DecrementStackCount()
		end
	end
end

function bald_3_modifier_passive_stack:OnDestroy()
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------