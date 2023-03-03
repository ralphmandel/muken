druid_5__seed = class({})
LinkLuaModifier("druid_5_modifier_seed", "heroes/druid/druid_5_modifier_seed", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function druid_5__seed:OnSpellStart()
    local caster = self:GetCaster()
  end

-- EFFECTS
