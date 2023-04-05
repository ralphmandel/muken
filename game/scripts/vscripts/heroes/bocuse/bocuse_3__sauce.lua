bocuse_3__sauce = class({})
LinkLuaModifier("bocuse_3_modifier_passive", "heroes/bocuse/bocuse_3_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bocuse_3_modifier_sauce", "heroes/bocuse/bocuse_3_modifier_sauce", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_break", "modifiers/_modifier_break", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_silence", "modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_disarm", "modifiers/_modifier_disarm", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function bocuse_3__sauce:GetIntrinsicModifierName()
		return "bocuse_3_modifier_passive"
	end

-- EFFECTS