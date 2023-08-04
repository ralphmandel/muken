genuine_u__morning = class({})
LinkLuaModifier("genuine_u_modifier_passive", "heroes/moon/genuine/genuine_u_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_u_modifier_morning", "heroes/moon/genuine/genuine_u_modifier_morning", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("genuine_u_modifier_curse", "heroes/moon/genuine/genuine_u_modifier_curse", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_buff", "_modifiers/_modifier_movespeed_buff", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function genuine_u__morning:Spawn()
    self.kills = 0
  end

  function genuine_u__morning:GetIntrinsicModifierName()
    return "genuine_u_modifier_passive"
  end

-- SPELL START

  function genuine_u__morning:OnAbilityPhaseStart()
    self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName()):PlayEfxBuff()
    return true
  end

  function genuine_u__morning:OnAbilityPhaseInterrupted()
    self:GetCaster():FindModifierByName(self:GetIntrinsicModifierName()):StopEfxBuff()
  end

  function genuine_u__morning:OnSpellStart()
    local caster = self:GetCaster()
    AddModifier(caster, self, "genuine_u_modifier_morning", {duration = self:GetSpecialValueFor("duration") + 0.2}, false)
  end

-- EFFECTS