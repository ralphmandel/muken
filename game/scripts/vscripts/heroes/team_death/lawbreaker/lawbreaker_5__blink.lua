lawbreaker_5__blink = class({})
LinkLuaModifier("lawbreaker_5_modifier_blink", "heroes/team_death/lawbreaker/lawbreaker_5_modifier_blink", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function lawbreaker_5__blink:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS