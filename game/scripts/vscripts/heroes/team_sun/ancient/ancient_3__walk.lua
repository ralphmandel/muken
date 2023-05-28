ancient_3__walk = class({})
LinkLuaModifier("ancient_3_modifier_walk", "heroes/team_sun/ancient/ancient_3_modifier_walk", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_3_modifier_casting", "heroes/team_sun/ancient/ancient_3_modifier_casting", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_3_modifier_efx_hands", "heroes/team_sun/ancient/ancient_3_modifier_efx_hands", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_3_modifier_debuff", "heroes/team_sun/ancient/ancient_3_modifier_debuff", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_petrified", "_modifiers/_modifier_petrified", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_petrified_status_efx", "_modifiers/_modifier_petrified_status_efx", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function ancient_3__walk:GetCastPoint()
    local channel = self:GetCaster():FindAbilityByName("_channel")
    local channel_time = self:GetSpecialValueFor("cast_point")
    return channel_time * (1 - (channel:GetLevel() * channel:GetSpecialValueFor("channel") * 0.01))
  end

  function ancient_3__walk:GetAOERadius()
    return self:GetSpecialValueFor("radius")
  end

  function ancient_3__walk:OnOwnerSpawned()
    self:SetActivated(true)
  end

-- SPELL START

  function ancient_3__walk:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    local time = self:GetChannelTime()

    caster:RemoveModifierByName("ancient_3_modifier_walk")
    caster:RemoveModifierByName("ancient_3_modifier_casting")
    AddModifier(caster, caster, self, "ancient_3_modifier_casting", {}, false)

    return true
  end

  function ancient_3__walk:OnAbilityPhaseInterrupted()
    local caster = self:GetCaster()
    caster:RemoveModifierByName("ancient_3_modifier_casting")
  end

  function ancient_3__walk:OnSpellStart()
    local caster = self:GetCaster()

    caster:RemoveModifierByName("ancient_3_modifier_casting")
    AddModifier(caster, caster, self, "ancient_3_modifier_walk", {duration = self:GetSpecialValueFor("duration")}, true)
  end

-- EFFECTS