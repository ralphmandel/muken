templar_u__praise = class({})
LinkLuaModifier("templar_u_modifier_praise", "heroes/sun/templar/templar_u_modifier_praise", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

	function templar_u__praise:OnSpellStart()
		local caster = self:GetCaster()
    caster:RemoveModifierByName("templar_u_modifier_praise")
    AddModifier(caster, caster, self, "templar_u_modifier_praise", {duration = self:GetSpecialValueFor("duration")}, true)
	end

-- EFFECTS