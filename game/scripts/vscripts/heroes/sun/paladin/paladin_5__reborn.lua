paladin_5__reborn = class({})
LinkLuaModifier("paladin_5_modifier_reborn", "heroes/sun/paladin/paladin_5_modifier_reborn", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function paladin_5__reborn:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS