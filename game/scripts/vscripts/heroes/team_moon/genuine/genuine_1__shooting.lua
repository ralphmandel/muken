genuine_1__shooting = class({})
LinkLuaModifier("genuine_1_modifier_shooting", "heroes/team_moon/genuine/genuine_1_modifier_shooting", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function genuine_1__shooting:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS