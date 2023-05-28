bald_3__inner = class({})
LinkLuaModifier("bald_3_modifier_passive", "heroes/team_sun/bald/bald_3_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bald_3_modifier_inner", "heroes/team_sun/bald/bald_3_modifier_inner", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_percent_movespeed_debuff", "_modifiers/_modifier_percent_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function bald_3__inner:Spawn()
    self.stack = 0
  end

-- SPELL START

  function bald_3__inner:GetIntrinsicModifierName()
    return "bald_3_modifier_passive"
  end

  function bald_3__inner:OnOwnerSpawned()
    self:ResetModifierStack()
  end

  function bald_3__inner:OnSpellStart()
    local caster = self:GetCaster()
    if IsServer() then
      local modifier = caster:FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), caster)
      modifier:StartIntervalThink(-1)
      modifier:SetStackCount(modifier:GetStackCount() + self:GetSpecialValueFor("bonus_stack"))
    end

    caster:AddNewModifier(caster, self, "bald_3_modifier_inner", {
      duration = CalcStatus(self:GetSpecialValueFor("buff_duration"), caster, caster)
    })
  end

  function bald_3__inner:ResetModifierStack()
    if IsServer() then
      local modifier = self:GetCaster():FindModifierByNameAndCaster(self:GetIntrinsicModifierName(), self:GetCaster())
      modifier:StartIntervalThink(-1)
      modifier:SetStackCount(0)
    end
  end

-- EFFECTS