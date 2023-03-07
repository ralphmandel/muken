_boss__ai = class({})
LinkLuaModifier("_boss_modifier__ai", "bosses/_boss_modifier__ai", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_invulnerable", "modifiers/_modifier_invulnerable", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

function _boss__ai:GetIntrinsicModifierName()
	return "_boss_modifier__ai"
end