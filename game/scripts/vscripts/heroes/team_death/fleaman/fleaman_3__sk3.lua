fleaman_3__jump = class({})
LinkLuaModifier("fleaman_3_modifier_jump", "heroes/team_death/fleaman/fleaman_3_modifier_jump", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function fleaman_3__jump:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS