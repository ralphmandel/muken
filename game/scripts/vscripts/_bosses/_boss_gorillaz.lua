_boss_gorillaz = class({})
LinkLuaModifier("_boss_gorillaz_modifier_passive", "_bosses/_boss_gorillaz_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("mk_gorillaz_buff", "_bosses/mk_gorillaz_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "_modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

function _boss_gorillaz:GetIntrinsicModifierName()
	return "_boss_gorillaz_modifier_passive"
end