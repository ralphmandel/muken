shrine = class({})
LinkLuaModifier("shrine_modifier", "_basics/shrine_modifier", LUA_MODIFIER_MOTION_NONE)

function shrine:GetIntrinsicModifierName()
	return "shrine_modifier"
end