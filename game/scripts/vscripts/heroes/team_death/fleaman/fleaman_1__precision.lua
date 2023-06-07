fleaman_1__precision = class({})
LinkLuaModifier("fleaman_1_modifier_precision", "heroes/team_death/fleaman/fleaman_1_modifier_precision", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function fleaman_1__precision:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS