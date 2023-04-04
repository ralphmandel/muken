stun_hits = class({})
LinkLuaModifier( "stun_hits_modifier", "neutrals/stun_hits_modifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)


function stun_hits:GetIntrinsicModifierName()
	return "stun_hits_modifier"
end