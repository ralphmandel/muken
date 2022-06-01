shadow_0_modifier_toxin_stack = class({})
local tempTable = require("libraries/tempTable")

function shadow_0_modifier_toxin_stack:IsPurgable()
	return false
end

function shadow_0_modifier_toxin_stack:IsHidden()
	return true
end

function shadow_0_modifier_toxin_stack:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function shadow_0_modifier_toxin_stack:OnCreated( kv )
	if IsServer() then
		self.modifier = tempTable:RetATValue( kv.modifier )
	end
end

function shadow_0_modifier_toxin_stack:OnRemoved()
	if IsServer() then
		if not self.modifier:IsNull() then
			self.modifier:DecrementStackCount()
		end
	end
end

function shadow_0_modifier_toxin_stack:OnDestroy()
end