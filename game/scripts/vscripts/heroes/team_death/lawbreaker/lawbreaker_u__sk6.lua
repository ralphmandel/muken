lawbreaker_u__sk6 = class({})
LinkLuaModifier("lawbreaker_u_modifier_sk6", "heroes/team_death/lawbreaker/lawbreaker_u_modifier_sk6", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function lawbreaker_u__sk6:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS