templar_3__circle = class({})
LinkLuaModifier("templar_3_modifier_circle", "heroes/sun/templar/templar_3_modifier_circle", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

function templar_3__circle:GetAOERadius()
  return self:GetSpecialValueFor("radius")
end

-- SPELL START

	function templar_3__circle:OnSpellStart()
		local caster = self:GetCaster()
    local loc = self:GetCursorPosition()

    if IsServer() then caster:EmitSound("Hero_Oracle.RainOfDestiny.Cast") end

    CreateModifierThinker(caster, self, "templar_3_modifier_circle", {
      duration = self:GetSpecialValueFor("duration"),
    }, loc, caster:GetTeamNumber(), false)
	end

-- EFFECTS