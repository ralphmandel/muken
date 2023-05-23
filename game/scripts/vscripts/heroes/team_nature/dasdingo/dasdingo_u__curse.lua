dasdingo_u__curse = class({})
LinkLuaModifier("dasdingo_u_modifier_curse", "heroes/team_nature/dasdingo/dasdingo_u_modifier_curse", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function dasdingo_u__curse:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS