strike = class({})
LinkLuaModifier("strike_modifier", "neutrals/strike_modifier", LUA_MODIFIER_MOTION_NONE)


function strike:GetIntrinsicModifierName()
	return "strike_modifier"
end