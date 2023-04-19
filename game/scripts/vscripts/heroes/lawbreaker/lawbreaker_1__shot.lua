lawbreaker_1__shot = class({})
LinkLuaModifier("lawbreaker_1_modifier_passive", "heroes/lawbreaker/lawbreaker_1_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function lawbreaker_1__shot:GetIntrinsicModifierName()
		return "lawbreaker_1_modifier_passive"
	end

-- EFFECTS