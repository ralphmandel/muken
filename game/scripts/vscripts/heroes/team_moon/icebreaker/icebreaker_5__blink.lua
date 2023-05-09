icebreaker_5__blink = class({})
LinkLuaModifier("icebreaker_5_modifier_blink", "heroes/team_moon/icebreaker/icebreaker_5_modifier_blink", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function icebreaker_5__blink:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS