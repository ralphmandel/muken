_modifier_restrict = class({})

--------------------------------------------------------------------------------
function _modifier_restrict:IsHidden()
	return false
end

function _modifier_restrict:IsPurgable()
	return true
end

function _modifier_restrict:GetTexture()
	return "_modifier_restrict"
end

function _modifier_restrict:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_restrict:OnCreated( kv )
end

--------------------------------------------------------------------------------

function _modifier_restrict:CheckState()
	local state = {
	[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}

	return state
end