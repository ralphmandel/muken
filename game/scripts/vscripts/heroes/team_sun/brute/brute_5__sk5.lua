brute_5__sk5 = class({})
LinkLuaModifier("brute_5_modifier_sk5", "heroes/team_sun/brute/brute_5_modifier_sk5", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function brute_5__sk5:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS