ancient_u__final = class({})
LinkLuaModifier("ancient_u_modifier_final", "heroes/team_sun/ancient/ancient_u_modifier_final", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function ancient_u__final:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS