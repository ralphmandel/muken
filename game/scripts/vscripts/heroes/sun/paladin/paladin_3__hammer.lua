paladin_3__hammer = class({})
LinkLuaModifier("paladin_3_modifier_hammer", "heroes/sun/paladin/paladin_3_modifier_hammer", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function paladin_3__hammer:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS