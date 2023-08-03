templar_2__barrier = class({})
LinkLuaModifier("templar_2_modifier_barrier", "heroes/sun/templar/templar_2_modifier_barrier", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function templar_2__barrier:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    target:RemoveModifierByNameAndCaster("templar_2_modifier_barrier", caster)
    AddModifier(target, caster, self, "templar_2_modifier_barrier", {duration = self:GetSpecialValueFor("duration")}, true)
  end

-- EFFECTS