lawbreaker_4__sk4 = class({})
LinkLuaModifier("lawbreaker_4_modifier_sk4", "heroes/team_death/lawbreaker/lawbreaker_4_modifier_sk4", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function lawbreaker_4__sk4:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS