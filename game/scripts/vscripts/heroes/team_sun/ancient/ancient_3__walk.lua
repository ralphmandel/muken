ancient_3__walk = class({})
LinkLuaModifier("ancient_3_modifier_walk", "heroes/team_sun/ancient/ancient_3_modifier_walk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function ancient_3__walk:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS