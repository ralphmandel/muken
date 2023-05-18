ancient_4__flesh = class({})
LinkLuaModifier("ancient_4_modifier_flesh", "heroes/team_sun/ancient/ancient_4_modifier_flesh", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function ancient_4__flesh:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS