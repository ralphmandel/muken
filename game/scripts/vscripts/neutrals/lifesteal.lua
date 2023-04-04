lifesteal = class({})
LinkLuaModifier( "lifesteal_modifier", "neutrals/lifesteal_modifier", LUA_MODIFIER_MOTION_NONE )

function lifesteal:GetIntrinsicModifierName()
	return "lifesteal_modifier"
end