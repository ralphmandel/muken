strike = class({})
LinkLuaModifier("strike_modifier", "neutrals/strike_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

function strike:GetIntrinsicModifierName()
	return "strike_modifier"
end