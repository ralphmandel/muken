paladin_2__shield = class({})
LinkLuaModifier("paladin_2_modifier_shield", "heroes/sun/paladin/paladin_2_modifier_shield", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function paladin_2__shield:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS