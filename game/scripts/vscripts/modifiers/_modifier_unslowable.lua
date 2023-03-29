_modifier_unslowable = class({})

--------------------------------------------------------------------------------
function _modifier_unslowable:IsPurgable()
	return false
end

function _modifier_unslowable:IsHidden()
	return true
end

function _modifier_unslowable:GetTexture()
	return "_modifier_unslowable"
end

function _modifier_unslowable:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_unslowable:OnCreated( kv )
end

--------------------------------------------------------------------------------

function _modifier_unslowable:CheckState()
	local state = {
		[MODIFIER_STATE_UNSLOWABLE] = true,
	}

	return state
end

--------------------------------------------------------------------------------
