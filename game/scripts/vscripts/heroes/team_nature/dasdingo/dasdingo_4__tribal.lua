dasdingo_4__tribal = class({})
LinkLuaModifier("dasdingo_4_modifier_tribal", "heroes/team_nature/dasdingo/dasdingo_4_modifier_tribal", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "_modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function dasdingo_4__tribal:OnSpellStart()
    local caster = self:GetCaster()
    local point = self:GetCursorPosition()
    local shard = CreateUnitByName("dasdingo_tribal", point, true, caster, caster, caster:GetTeamNumber())

    shard:CreatureLevelUp(self:GetSpecialValueFor("rank"))
    shard:SetControllableByPlayer(caster:GetPlayerOwnerID(), true)
    AddModifier(shard, caster, self, "dasdingo_4_modifier_tribal", {duration = self:GetSpecialValueFor("duration")}, true)
  end

-- EFFECTS