genuine_u__morning = class({})
LinkLuaModifier("genuine_u_modifier_morning", "heroes/moon_team/genuine/genuine_u_modifier_morning", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function genuine_u__morning:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS