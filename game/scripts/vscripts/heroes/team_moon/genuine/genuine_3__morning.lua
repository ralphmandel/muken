genuine_3__morning = class({})
LinkLuaModifier("genuine_3_modifier_morning", "heroes/team_moon/genuine/genuine_3_modifier_morning", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function genuine_3__morning:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS