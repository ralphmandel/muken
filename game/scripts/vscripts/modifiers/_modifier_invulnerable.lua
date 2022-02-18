_modifier_invulnerable = class({})

--------------------------------------------------------------------------------
function _modifier_invulnerable:IsPurgable()
	return true
end

function _modifier_invulnerable:IsHidden()
	return true
end

function _modifier_invulnerable:IsDebuff()
	return false
end

function _modifier_invulnerable:GetTexture()
	return "_modifier_invulnerable"
end

function _modifier_invulnerable:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_invulnerable:OnCreated( kv )
end

--------------------------------------------------------------------------------

function _modifier_invulnerable:CheckState()
	local state = {
	[MODIFIER_STATE_INVULNERABLE] = true,
	}

	return state
end

--------------------------------------------------------------------------------
