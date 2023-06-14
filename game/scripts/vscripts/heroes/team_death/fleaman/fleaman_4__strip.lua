fleaman_4__strip = class({})
LinkLuaModifier("fleaman_4_modifier_strip", "heroes/team_death/fleaman/fleaman_4_modifier_strip", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function fleaman_4__strip:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS