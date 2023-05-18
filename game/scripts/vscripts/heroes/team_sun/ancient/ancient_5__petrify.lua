ancient_5__petrify = class({})
LinkLuaModifier("ancient_5_modifier_petrify", "heroes/team_sun/ancient/ancient_5_modifier_petrify", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function ancient_5__petrify:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS