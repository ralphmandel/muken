bald_3__inner = class({})
LinkLuaModifier("bald_3_modifier_passive", "heroes/bald/bald_3_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bald_3_modifier_passive_stack", "heroes/bald/bald_3_modifier_passive_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bald_3_modifier_inner", "heroes/bald/bald_3_modifier_inner", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function bald_3__inner:GetIntrinsicModifierName()
    return "bald_3_modifier_passive"
  end

  function bald_3__inner:OnSpellStart()
    local caster = self:GetCaster()
    local modifier = caster:FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), caster)
    local stack = modifier:GetStackCount() + self:GetSpecialValueFor("bonus_stack")

    caster:RemoveModifierByName("bald_3_modifier_passive_stack")
    caster:AddNewModifier(caster, self, "bald_3_modifier_inner", {
      duration = CalcStatus(self:GetSpecialValueFor("buff_duration"), caster, caster), stack = stack
    })
  end

-- EFFECTS