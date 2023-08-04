templar_u__praise = class({})
LinkLuaModifier("templar_u_modifier_praise", "heroes/sun/templar/templar_u_modifier_praise", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("templar_u_modifier_praise_status_efx", "heroes/sun/templar/templar_u_modifier_praise_status_efx", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function templar_u__praise:OnSpellStart()
		local caster = self:GetCaster()
    caster:RemoveModifierByName("templar_u_modifier_praise")
    AddModifier(caster, self, "templar_u_modifier_praise", {duration = self:GetSpecialValueFor("duration")}, true)
	end

-- EFFECTS