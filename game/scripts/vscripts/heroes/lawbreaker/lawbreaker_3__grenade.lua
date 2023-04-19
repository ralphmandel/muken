lawbreaker_3__grenade = class({})
LinkLuaModifier("lawbreaker_3_modifier_grenade", "heroes/lawbreaker/lawbreaker_3_modifier_grenade", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function lawbreaker_3__grenade:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS