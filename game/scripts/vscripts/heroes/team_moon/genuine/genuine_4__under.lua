genuine_4__under = class({})
LinkLuaModifier("genuine_4_modifier_under", "heroes/moon_team/genuine/genuine_4_modifier_under", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function genuine_4__under:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS