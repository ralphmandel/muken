_boss_gorillaz = class({})
LinkLuaModifier("_boss_gorillaz_modifier_passive", "bosses/_boss_gorillaz_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("mk_gorillaz_buff", "bosses/mk_gorillaz_buff", LUA_MODIFIER_MOTION_NONE)

function _boss_gorillaz:GetIntrinsicModifierName()
	return "_boss_gorillaz_modifier_passive"
end