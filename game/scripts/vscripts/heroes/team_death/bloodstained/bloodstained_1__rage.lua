bloodstained_1__rage = class({})
LinkLuaModifier("bloodstained_1_modifier_rage", "heroes/team_death/bloodstained/bloodstained_1_modifier_rage", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("bloodstained_1_modifier_rage_status_efx", "heroes/team_death/bloodstained/bloodstained_1_modifier_rage_status_efx", LUA_MODIFIER_MOTION_NONE)

-- INIT

-- SPELL START

  function bloodstained_1__rage:OnOwnerSpawned()
    self:SetActivated(true)
  end

  function bloodstained_1__rage:OnSpellStart()
    local caster = self:GetCaster()
    AddModifier(caster, caster, self, "bloodstained_1_modifier_rage", {duration = self:GetSpecialValueFor("duration")}, true)
    
    if IsServer() then
      caster:EmitSound("Hero_PhantomAssassin.CoupDeGrace")
      caster:EmitSound("Bloodstained.fury")
      caster:EmitSound("Bloodstained.rage")
    end
  end

-- EFFECTS