genuine_u__star = class({})
LinkLuaModifier("genuine_u_modifier_star", "heroes/team_moon/genuine/genuine_u_modifier_star", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function genuine_u__star:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS