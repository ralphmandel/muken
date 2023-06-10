lawbreaker_1__shot = class({})
LinkLuaModifier("lawbreaker_1_modifier_passive", "heroes/team_death/lawbreaker/lawbreaker_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function lawbreaker_1__shot:GetIntrinsicModifierName()
		return "lawbreaker_1_modifier_passive"
	end

-- EFFECTS