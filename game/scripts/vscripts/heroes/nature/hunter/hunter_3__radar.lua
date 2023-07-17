hunter_3__radar = class({})
LinkLuaModifier("hunter_3_modifier_radar", "heroes/nature/hunter/hunter_3_modifier_radar", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function hunter_3__radar:GetAOERadius()
    return self:GetSpecialValueFor("radius")
  end

-- SPELL START

	function hunter_3__radar:OnSpellStart()
		local caster = self:GetCaster()
    local point = self:GetCursorPosition()

    CreateModifierThinker(caster, self, "hunter_3_modifier_radar", {}, point, caster:GetTeamNumber(), false)
	end

-- EFFECTS