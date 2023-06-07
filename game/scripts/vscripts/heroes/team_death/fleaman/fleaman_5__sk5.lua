fleaman_5__steal = class({})
LinkLuaModifier("fleaman_5_modifier_steal", "heroes/team_death/fleaman/fleaman_5_modifier_steal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function fleaman_5__steal:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS