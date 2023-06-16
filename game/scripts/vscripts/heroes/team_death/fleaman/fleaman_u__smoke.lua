fleaman_u__smoke = class({})
LinkLuaModifier("fleaman_u_modifier_smoke", "heroes/team_death/fleaman/fleaman_u_modifier_smoke", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "_modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function fleaman_u__smoke:GetAOERadius()
    return self:GetSpecialValueFor("radius")
  end

-- SPELL START

  function fleaman_u__smoke:OnSpellStart()
		local caster = self:GetCaster()

		CreateModifierThinker(caster, self, "fleaman_u_modifier_smoke", {
      duration = self:GetSpecialValueFor("duration")
    }, self:GetCursorPosition(), caster:GetTeamNumber(), false)
	end

-- EFFECTS