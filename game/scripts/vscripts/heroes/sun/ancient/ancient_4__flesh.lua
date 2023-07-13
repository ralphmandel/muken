ancient_4__flesh = class({})
LinkLuaModifier("ancient_4_modifier_passive", "heroes/sun/ancient/ancient_4_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function ancient_4__flesh:GetIntrinsicModifierName()
		return "ancient_4_modifier_passive"
	end

-- EFFECTS