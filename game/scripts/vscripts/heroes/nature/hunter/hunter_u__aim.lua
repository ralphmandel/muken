hunter_u__aim = class({})
LinkLuaModifier("hunter_u_modifier_aim", "heroes/nature/hunter/hunter_u_modifier_aim", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function hunter_u__aim:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS