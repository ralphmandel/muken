dasdingo_3__leech = class({})
LinkLuaModifier("dasdingo_3_modifier_leech", "heroes/team_nature/dasdingo/dasdingo_3_modifier_leech", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function dasdingo_3__leech:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS