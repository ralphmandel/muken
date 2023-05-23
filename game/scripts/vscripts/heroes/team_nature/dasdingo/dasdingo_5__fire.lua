dasdingo_5__fire = class({})
LinkLuaModifier("dasdingo_5_modifier_fire", "heroes/team_nature/dasdingo/dasdingo_5_modifier_fire", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function dasdingo_5__fire:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS