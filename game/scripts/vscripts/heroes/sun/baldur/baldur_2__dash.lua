baldur_2__dash = class({})
LinkLuaModifier("baldur_2_modifier_dash", "heroes/sun/baldur/baldur_2_modifier_dash", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function baldur_2__dash:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS