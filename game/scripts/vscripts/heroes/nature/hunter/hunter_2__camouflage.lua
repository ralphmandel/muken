hunter_2__camouflage = class({})
LinkLuaModifier("hunter_2_modifier_camouflage", "heroes/nature/hunter/hunter_2_modifier_camouflage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function hunter_2__camouflage:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS