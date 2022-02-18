_modifier_break = class({})

--------------------------------------------------------------------------------
function _modifier_break:IsPurgable()
	return true
end

function _modifier_break:IsHidden()
	return false
end

function _modifier_break:IsDebuff()
	return true
end

function _modifier_break:GetTexture()
	return "_modifier_break"
end

function _modifier_break:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_break:OnCreated( kv )
end

--------------------------------------------------------------------------------

function _modifier_break:CheckState()
	local state = {
	[MODIFIER_STATE_PASSIVES_DISABLED] = true,
	}

	return state
end

--------------------------------------------------------------------------------
