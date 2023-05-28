genuine_2__fallen = class({})
LinkLuaModifier("genuine_2_modifier_fallen", "heroes/team_moon/genuine/genuine_2_modifier_fallen", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function genuine_2__fallen:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS