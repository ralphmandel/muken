mana_burn = class({})
LinkLuaModifier("mana_burn_modifier", "neutrals/mana_burn_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

function mana_burn:GetIntrinsicModifierName()
	return "mana_burn_modifier"
end