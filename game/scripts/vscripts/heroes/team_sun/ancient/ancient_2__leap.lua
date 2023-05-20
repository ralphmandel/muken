ancient_2__leap = class({})
LinkLuaModifier("ancient_2_modifier_charges", "heroes/team_sun/ancient/ancient_2_modifier_charges", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_2_modifier_leap", "heroes/team_sun/ancient/ancient_2_modifier_leap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_2_modifier_jump", "heroes/team_sun/ancient/ancient_2_modifier_jump", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("_modifier_generic_arc", "modifiers/_modifier_generic_arc", LUA_MODIFIER_MOTION_BOTH)

-- INIT

  function ancient_2__leap:Spawn()
    self:SetCurrentAbilityCharges(1)

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

  function ancient_2__leap:GetBehavior()
    if self:GetCurrentAbilityCharges() == 2 then
      return DOTA_ABILITY_BEHAVIOR_NO_TARGET + DOTA_ABILITY_BEHAVIOR_IMMEDIATE
    end

    return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE
  end

  function ancient_2__leap:GetCastRange(vLocation, hTarget)
    if self:GetCurrentAbilityCharges() == 2 then return 0 end

    return self:GetSpecialValueFor("jump_distance")
  end

-- SPELL START

  function ancient_2__leap:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    self.point = self:GetCursorPosition()
    self.distance = (caster:GetOrigin() - self.point):Length2D()
    self.duration = self.distance / (self:GetCastRange(nil, nil) * 1.4)
    self.height = self.distance * 0.5

    caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1)

    if self.duration < 0.4 then
      Timers:CreateTimer((self.duration), function()
        caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
        caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_5, 1)
        if IsServer() then caster:EmitSound("Hero_ElderTitan.PreAttack") end
      end)
    end

    if self.duration >= 0.5 then
      Timers:CreateTimer((0.2), function()
        if IsServer() then caster:EmitSound("Ancient.Jump") end
      end)
    end

    return true
  end

  function ancient_2__leap:OnSpellStart()
    local caster = self:GetCaster()
    self.aggro_target = caster:GetAggroTarget()
    self:EndCooldown()
    caster:Hold()

    caster:RemoveModifierByName("ancient_2_modifier_jump")
    caster:RemoveModifierByName("ancient_2_modifier_leap")

    if self:GetCurrentAbilityCharges() == 1 then
      AddModifier(caster, caster, self, "ancient_2_modifier_jump", {}, false)
    end

    if self:GetCurrentAbilityCharges() == 2 then
      AddModifier(caster, caster, self, "ancient_2_modifier_leap", {}, false)
    end
  end

-- EFFECTS