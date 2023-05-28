strike = class({})
LinkLuaModifier("strike_modifier", "_neutrals/strike_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("strike_modifier_slow", "_neutrals/strike_modifier_slow", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("strike_modifier_speed", "_neutrals/strike_modifier_speed", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "_modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "_modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

function strike:GetIntrinsicModifierName()
	return "strike_modifier"
end