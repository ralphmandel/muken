_boss__ai = class({})
LinkLuaModifier("_boss_modifier__ai", "_bosses/_boss_modifier__ai", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_immunity", "_modifiers/_modifier_immunity", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "_modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

function _boss__ai:GetIntrinsicModifierName()
	return "_boss_modifier__ai"
end