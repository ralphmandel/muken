templar_u__praise = class({})
LinkLuaModifier("templar_u_modifier_praise", "heroes/sun/templar/templar_u_modifier_praise", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function templar_u__praise:OnSpellStart()
		local caster = self:GetCaster()
	end

-- EFFECTS