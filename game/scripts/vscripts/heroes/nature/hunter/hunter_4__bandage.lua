hunter_4__bandage = class({})
LinkLuaModifier("hunter_4_modifier_bandage", "heroes/nature/hunter/hunter_4_modifier_bandage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function hunter_4__bandage:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS