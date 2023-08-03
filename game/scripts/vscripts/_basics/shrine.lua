shrine = class({})
LinkLuaModifier("shrine_modifier", "_basics/shrine_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shrine_refresh_hp_modifier", "_basics/shrine_refresh_hp_modifier", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("shrine_refresh_mp_modifier", "_basics/shrine_refresh_mp_modifier", LUA_MODIFIER_MOTION_NONE)

function shrine:GetIntrinsicModifierName()
	return "shrine_modifier"
end