_neutral__ai = class({})
LinkLuaModifier( "_modifier__ai", "neutrals/_modifier__ai", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("_modifier_invulnerable", "modifiers/_modifier_invulnerable", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

function _neutral__ai:GetIntrinsicModifierName()
	return "_modifier__ai"
end