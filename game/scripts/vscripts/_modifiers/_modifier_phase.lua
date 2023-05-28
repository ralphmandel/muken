_modifier_phase = class({})

--------------------------------------------------------------------------------
function _modifier_phase:IsPurgable()
	return true
end

function _modifier_phase:IsHidden()
	return false
end

function _modifier_phase:GetTexture()
	return "_modifier_phase"
end

function _modifier_phase:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_phase:OnCreated( kv )
end

--------------------------------------------------------------------------------

function _modifier_phase:CheckState()
	local state = {
	[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
	}

	return state
end

--------------------------------------------------------------------------------
