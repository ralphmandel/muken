templar_3__circle = class({})
LinkLuaModifier("templar_3_modifier_circle", "heroes/sun/templar/templar_3_modifier_circle", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function templar_3__circle:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS