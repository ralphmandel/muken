lawbreaker_u__form = class({})
LinkLuaModifier("lawbreaker_u_modifier_form", "heroes/team_death/lawbreaker/lawbreaker_u_modifier_form", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function lawbreaker_u__form:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS