_modifier_hex = class({})

--------------------------------------------------------------------------------
function _modifier_hex:IsPurgable()
	return true
end

function _modifier_hex:IsHidden()
	return false
end

function _modifier_hex:GetTexture()
	return "_modifier_hex"
end

function _modifier_hex:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_hex:OnCreated( kv )
end

--------------------------------------------------------------------------------

function _modifier_hex:CheckState()
	local state = {
		[MODIFIER_STATE_PASSIVES_DISABLED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
