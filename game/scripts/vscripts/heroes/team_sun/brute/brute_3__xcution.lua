brute_3__xcution = class({})
LinkLuaModifier("brute_3_modifier_xcution", "heroes/team_sun/brute/brute_3_modifier_xcution", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function brute_3__xcution:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS