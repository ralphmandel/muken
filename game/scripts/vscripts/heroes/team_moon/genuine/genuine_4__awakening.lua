genuine_4__awakening = class({})
LinkLuaModifier("genuine_4_modifier_awakening", "heroes/team_moon/genuine/genuine_4_modifier_awakening", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function genuine_4__awakening:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS