fleaman_2_modifier_speed_stack = class({})
local tempTable = require("libraries/tempTable")

function fleaman_2_modifier_speed_stack:IsPurgable() return true end
function fleaman_2_modifier_speed_stack:IsHidden() return true end
function fleaman_2_modifier_speed_stack:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

-- CONSTRUCTORS -----------------------------------------------------------

function fleaman_2_modifier_speed_stack:OnCreated( kv )
	if IsServer() then
		self.modifier = tempTable:RetATValue( kv.modifier )
	end
end

function fleaman_2_modifier_speed_stack:OnRemoved()
	if IsServer() then
		if not self.modifier:IsNull() then
			self.modifier:DecrementStackCount()
		end
	end
end

function fleaman_2_modifier_speed_stack:OnDestroy()
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------