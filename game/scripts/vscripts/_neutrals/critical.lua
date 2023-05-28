critical = class({})
LinkLuaModifier( "critical_modifier", "_neutrals/critical_modifier", LUA_MODIFIER_MOTION_NONE )

function critical:GetIntrinsicModifierName()
	return "critical_modifier"
end