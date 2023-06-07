fleaman_2__speed = class({})
LinkLuaModifier("fleaman_2_modifier_speed", "heroes/team_death/fleaman/fleaman_2_modifier_speed", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function fleaman_2__speed:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS