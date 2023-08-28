dasdingo_1__field = class({})
LinkLuaModifier("dasdingo_1_modifier_passive", "heroes/nature/dasdingo/dasdingo_1_modifier_field", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_1_modifier_field", "heroes/nature/dasdingo/dasdingo_1_modifier_field", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_1_modifier_aura_effect", "heroes/nature/dasdingo/dasdingo_1_modifier_aura_effect", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function dasdingo_1__field:GetAOERadius()
    return self:GetSpecialValueFor("radius")
  end

  function dasdingo_1__field:GetIntrinsicModifierName()
    return "dasdingo_1_modifier_passive"
  end

-- SPELL START

	function dasdingo_1__field:OnSpellStart()
		local caster = self:GetCaster()
    AddModifier(caster, self, "dasdingo_1_modifier_field", {duration = self:GetSpecialValueFor("duration")}, true)
	end

-- EFFECTS