baldur_4__rear = class({})
LinkLuaModifier("baldur_4_modifier_rear", "heroes/sun/baldur/baldur_4_modifier_rear", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function baldur_4__rear:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS