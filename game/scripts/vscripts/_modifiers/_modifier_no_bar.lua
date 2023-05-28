_modifier_no_bar = class({})

--------------------------------------------------------------------------------
-- Classifications
function _modifier_no_bar:IsHidden()
	return true
end

function _modifier_no_bar:IsPurgable()
    return false
end

function _modifier_no_bar:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------
-- Initializations
function _modifier_no_bar:OnCreated( kv )
end

function _modifier_no_bar:OnRemoved()
end

---------------------------------------------------------------------------------

function _modifier_no_bar:CheckState()
	local state = {
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
	}

	return state
end