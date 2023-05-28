_neutral__ai = class({})
LinkLuaModifier( "_modifier__ai", "_neutrals/_modifier__ai", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("_modifier_immunity", "_modifiers/_modifier_immunity", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "_modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

function _neutral__ai:GetIntrinsicModifierName()
	return "_modifier__ai"
end