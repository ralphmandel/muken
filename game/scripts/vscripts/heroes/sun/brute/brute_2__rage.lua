brute_2__rage = class({})
LinkLuaModifier("brute_2_modifier_rage", "heroes/sun/brute/brute_2_modifier_rage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function brute_2__rage:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS