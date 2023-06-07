fleaman_u__smoke = class({})
LinkLuaModifier("fleaman_u_modifier_smoke", "heroes/team_death/fleaman/fleaman_u_modifier_smoke", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function fleaman_u__smoke:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS