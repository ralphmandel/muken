ancient_2__leap = class({})
LinkLuaModifier("ancient_2_modifier_charges", "heroes/team_sun/ancient/ancient_2_modifier_charges", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_2_modifier_leap", "heroes/team_sun/ancient/ancient_2_modifier_leap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function ancient_2__leap:Spawn()
    if self:IsTrained() == false then
      self:UpgradeAbility(true)
    end
  end

  function ancient_2__leap:GetIntrinsicModifierName()
    return "ancient_2_modifier_charges"
  end

  function ancient_2__leap:GetAOERadius()
    return self:GetSpecialValueFor("radius")
  end

-- SPELL START

  function ancient_2__leap:OnSpellStart()
    local caster = self:GetCaster()
    self.aggro_target = caster:GetAggroTarget()
    self:EndCooldown()

    caster:Hold()
    caster:RemoveModifierByName("ancient_2_modifier_leap")
    AddModifier(caster, caster, self, "ancient_2_modifier_leap", {}, false)
  end

-- EFFECTS