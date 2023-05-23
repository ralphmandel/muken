dasdingo_2__shield = class({})
LinkLuaModifier("dasdingo_2_modifier_shield", "heroes/team_nature/dasdingo/dasdingo_2_modifier_shield", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function dasdingo_2__shield:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS