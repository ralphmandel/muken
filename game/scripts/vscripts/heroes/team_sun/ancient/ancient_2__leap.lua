ancient_2__leap = class({})
LinkLuaModifier("ancient_2_modifier_leap", "heroes/team_sun/ancient/ancient_2_modifier_leap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function ancient_2__leap:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS