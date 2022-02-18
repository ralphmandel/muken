_modifier_tracking = class({})

--------------------------------------------------------------------------------
function _modifier_tracking:IsPurgable()
	return true
end

function _modifier_tracking:IsHidden()
	return true
end

function _modifier_tracking:IsDebuff()
	return true
end

--------------------------------------------------------------------------------

function _modifier_tracking:OnCreated( kv )
end

function _modifier_tracking:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_tracking:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_PROVIDES_FOW_POSITION,
	}

	return funcs
end

function _modifier_tracking:GetModifierProvidesFOWVision()
	return 1
end

--------------------------------------------------------------------------------
