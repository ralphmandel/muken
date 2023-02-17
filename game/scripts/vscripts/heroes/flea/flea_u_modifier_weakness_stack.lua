flea_u_modifier_weakness_stack = class({})
local tempTable = require("libraries/tempTable")

function flea_u_modifier_weakness_stack:IsPurgable() return true end
function flea_u_modifier_weakness_stack:IsHidden() return true end
function flea_u_modifier_weakness_stack:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_u_modifier_weakness_stack:OnCreated( kv )
	if IsServer() then
		self.modifier = tempTable:RetATValue( kv.modifier )
	end
end

function flea_u_modifier_weakness_stack:OnRemoved()
	if IsServer() then
		if not self.modifier:IsNull() then
			self.modifier:ChangeStack(-1)
		end
	end
end

function flea_u_modifier_weakness_stack:OnDestroy()
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------