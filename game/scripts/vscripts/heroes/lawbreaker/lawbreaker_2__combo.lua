lawbreaker_2__combo = class({})
LinkLuaModifier("lawbreaker_2_modifier_combo", "heroes/lawbreaker/lawbreaker_2_modifier_combo", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function lawbreaker_2__combo:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS