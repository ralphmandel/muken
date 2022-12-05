bald_1_modifier_passive_stack = class({})
local tempTable = require("libraries/tempTable")

function bald_1_modifier_passive_stack:IsHidden() return true end
function bald_1_modifier_passive_stack:IsPurgable() return true end
function bald_1_modifier_passive_stack:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_1_modifier_passive_stack:OnCreated( kv )
	if IsServer() then
		self.modifier = tempTable:RetATValue( kv.modifier )
		self.stacks = kv.stacks
	end
end

function bald_1_modifier_passive_stack:OnRemoved()
	if IsServer() then
		if not self.modifier:IsNull() then
			self.modifier:SetStackCount(self.modifier:GetStackCount() - self.stacks)
		end
	end
end

function bald_1_modifier_passive_stack:OnDestroy()
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------