stun_hits = class({})
LinkLuaModifier( "stun_hits_modifier", "_neutrals/stun_hits_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)


function stun_hits:GetIntrinsicModifierName()
	return "stun_hits_modifier"
end