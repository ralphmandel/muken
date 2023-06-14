fleaman_3__jump = class({})
LinkLuaModifier("fleaman_3_modifier_jump", "heroes/team_death/fleaman/fleaman_3_modifier_jump", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("fleaman_3_modifier_effect", "heroes/team_death/fleaman/fleaman_3_modifier_effect", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_generic_arc", "_modifiers/_modifier_generic_arc", LUA_MODIFIER_MOTION_BOTH)
LinkLuaModifier("_modifier_silence", "_modifiers/_modifier_silence", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function fleaman_3__jump:GetIntrinsicModifierName()
    return "flea_3_modifier_passive"
  end

  function fleaman_3__jump:OnOwnerSpawned()
    self:SetActivated(true)
  end

-- SPELL START

  function fleaman_3__jump:OnSpellStart()
    local caster = self:GetCaster()

    ProjectileManager:ProjectileDodge(caster)
    caster:RemoveModifierByName("flea_3_modifier_jump")
    AddModifier(caster, caster, self, "fleaman_3_modifier_jump", {}, false)
  end

-- EFFECTS