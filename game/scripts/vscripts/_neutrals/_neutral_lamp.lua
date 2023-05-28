_neutral_lamp = class({})
LinkLuaModifier( "_modifier_neutral_lamp", "_neutrals/_modifier_neutral_lamp", LUA_MODIFIER_MOTION_NONE )


function _neutral_lamp:GetIntrinsicModifierName()
	return "_modifier_neutral_lamp"
end