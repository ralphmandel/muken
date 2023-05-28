_neutral_dragon = class({})
LinkLuaModifier( "_modifier_neutral_dragon", "_neutrals/_modifier_neutral_dragon", LUA_MODIFIER_MOTION_NONE )

function _neutral_dragon:GetIntrinsicModifierName()
	return "_modifier_neutral_dragon"
end