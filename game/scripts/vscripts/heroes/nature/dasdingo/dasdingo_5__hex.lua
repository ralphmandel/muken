dasdingo_5__hex = class({})
LinkLuaModifier("_modifier_hex", "_modifiers/_modifier_hex", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function dasdingo_5__hex:GetIntrinsicModifierName()
    return "dasdingo_5_modifier_passive"
  end

-- SPELL START

  function dasdingo_5__hex:OnSpellStart()
    local caster = self:GetCaster()
    local target = self:GetCursorTarget()

    if target:TriggerSpellAbsorb( self ) then return end

    AddModifier(target, caster, self, "_modifier_hex", {duration = self:GetSpecialValueFor("duration")}, true)
  end

-- EFFECTS