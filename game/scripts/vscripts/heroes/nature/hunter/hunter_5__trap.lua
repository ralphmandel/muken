hunter_5__trap = class({})
LinkLuaModifier("hunter_5_modifier_trap", "heroes/nature/hunter/hunter_5_modifier_trap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function hunter_5__trap:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS