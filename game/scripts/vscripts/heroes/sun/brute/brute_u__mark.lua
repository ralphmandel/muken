brute_u__mark = class({})
LinkLuaModifier("brute_u_modifier_mark", "heroes/sun/brute/brute_u_modifier_mark", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function brute_u__mark:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS