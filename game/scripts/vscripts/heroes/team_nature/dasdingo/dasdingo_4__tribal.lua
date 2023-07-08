dasdingo_4__tribal = class({})
LinkLuaModifier("dasdingo_4_modifier_tribal", "heroes/team_nature/dasdingo/dasdingo_4_modifier_tribal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function dasdingo_4__tribal:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local unit = CreateUnitByName("dasdingo_tribal", point, true, caster, caster, caster:GetTeamNumber())
    FindClearSpaceForUnit(unit, point, true)

    unit:CreatureLevelUp(self:GetSpecialValueFor("rank"))
    unit:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
    AddModifier(unit, caster, self, "dasdingo_4_modifier_tribal", {duration = self:GetSpecialValueFor("duration")}, true)
  end

-- EFFECTS