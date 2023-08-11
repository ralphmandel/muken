baldur_5__fire = class({})
LinkLuaModifier("baldur_5_modifier_fire", "heroes/sun/baldur/baldur_5_modifier_fire", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function baldur_5__fire:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS