burning_armor = class({})
LinkLuaModifier( "burning_armor_modifier", "_neutrals/burning_armor_modifier", LUA_MODIFIER_MOTION_NONE )

function burning_armor:GetIntrinsicModifierName()
	return "burning_armor_modifier"
end