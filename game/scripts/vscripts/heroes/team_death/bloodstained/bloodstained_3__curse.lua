bloodstained_3__curse = class({})
LinkLuaModifier("bloodstained_3_modifier_curse", "heroes/team_death/bloodstained/bloodstained_3_modifier_curse", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_movespeed_debuff", "_modifiers/_modifier_movespeed_debuff", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function bloodstained_3__curse:OnOwnerSpawned()
    self:SetActivated(true)
  end

-- SPELL START

  function bloodstained_3__curse:OnSpellStart()
    local caster = self:GetCaster()
    self.target = self:GetCursorTarget()
    
    if self.target:TriggerSpellAbsorb(self) then return end

    caster:RemoveModifierByNameAndCaster("bloodstained_3_modifier_curse", caster)
    AddModifier(self.target, caster, self, "bloodstained_3_modifier_curse", {}, false)

    if IsServer() then
      caster:EmitSound("Hero_ShadowDemon.DemonicPurge.Cast")
      self.target:EmitSound("Hero_Oracle.FortunesEnd.Attack")
    end
  end

-- EFFECTS