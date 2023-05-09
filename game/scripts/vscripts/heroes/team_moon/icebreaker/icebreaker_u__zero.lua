icebreaker_u__zero = class({})
LinkLuaModifier("icebreaker_u_modifier_zero", "heroes/team_moon/icebreaker/icebreaker_u_modifier_zero", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function icebreaker_u__zero:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS