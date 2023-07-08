dasdingo_1__field = class({})
LinkLuaModifier("dasdingo_1_modifier_field", "heroes/team_nature/dasdingo/dasdingo_1_modifier_field", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_1_modifier_aura_effect", "heroes/team_nature/dasdingo/dasdingo_1_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function dasdingo_1__field:GetAOERadius()
    return self:GetSpecialValueFor("radius")
  end

-- SPELL START

	function dasdingo_1__field:OnSpellStart()
		local caster = self:GetCaster()

    CreateModifierThinker(caster, self, "dasdingo_1_modifier_field", {
      duration = self:GetSpecialValueFor("duration") + 0.5
    }, self:GetCursorPosition(), caster:GetTeamNumber(), false)
	end

-- EFFECTS