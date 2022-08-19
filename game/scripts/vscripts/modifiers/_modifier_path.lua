_modifier_path = class({})

function _modifier_path:IsPurgable()
	return true
end

function _modifier_path:GetTexture()
	return "_modifier_path"
end

function _modifier_path:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------]

function _modifier_path:OnCreated( kv )
end

function _modifier_path:CheckState()
	local state = {
    	[MODIFIER_STATE_ALLOW_PATHING_THROUGH_CLIFFS] = true,
	}

	return state
end
