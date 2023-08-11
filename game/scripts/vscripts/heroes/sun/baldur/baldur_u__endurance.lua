baldur_u__endurance = class({})
LinkLuaModifier("baldur_u_modifier_endurance", "heroes/sun/baldur/baldur_u_modifier_endurance", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function baldur_u__endurance:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS