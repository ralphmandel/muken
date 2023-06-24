ancient_2__leap = class({})
LinkLuaModifier("ancient_2_modifier_charges", "heroes/team_sun/ancient/ancient_2_modifier_charges", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_2_modifier_leap", "heroes/team_sun/ancient/ancient_2_modifier_leap", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("ancient_2_modifier_jump", "heroes/team_sun/ancient/ancient_2_modifier_jump", LUA_MODIFIER_MOTION_HORIZONTAL)
LinkLuaModifier("_modifier_generic_arc", "_modifiers/_modifier_generic_arc", LUA_MODIFIER_MOTION_BOTH)

-- INIT

  function ancient_2__leap:Spawn()
    self.aggro_target = nil

    Timers:CreateTimer(0.2, function()
      if self:IsTrained() == false then
        self:UpgradeAbility(true)
        BaseStats(self:GetCaster()):AddManaExtra(self)
      end
    end)
  end

  function ancient_2__leap:GetIntrinsicModifierName()
    return "ancient_2_modifier_charges"
  end

  function ancient_2__leap:GetAOERadius()
    return self:GetSpecialValueFor("radius")
  end

  function ancient_2__leap:GetBehavior()
    if self:GetCastRange(nil, nil) > 0 then
      return DOTA_ABILITY_BEHAVIOR_POINT + DOTA_ABILITY_BEHAVIOR_AOE + DOTA_ABILITY_BEHAVIOR_ROOT_DISABLES
    end

    return DOTA_ABILITY_BEHAVIOR_NO_TARGET
  end

  function ancient_2__leap:GetCastRange(vLocation, hTarget)
    return self:GetSpecialValueFor("special_jump_distance")
  end

-- SPELL START

  function ancient_2__leap:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    self.point = self:GetCursorPosition()
    self.distance = (caster:GetOrigin() - self.point):Length2D()
    self.duration = self.distance / (((self:GetCastRange(nil, nil) - 100) / (self:GetCurrentAbilityCharges() * 0.7)) * 2.2)
    self.height = self.distance * 0.5
    self.interruption = false

    if caster:HasModifier("ancient_2_modifier_leap") then return false end

    if self:GetCastRange(nil, nil) > 0 then
      caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_1, 1)
      if self.duration < 0.4 then
        Timers:CreateTimer((self.duration), function()
          if self.interruption == false then
            caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
            caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_5, 1)
            if IsServer() then caster:EmitSound("Hero_ElderTitan.PreAttack") end
          end
        end)
      end
  
      if self.duration >= 0.5 then
        Timers:CreateTimer((0.2), function()
          if self.interruption == false then
            if IsServer() then caster:EmitSound("Ancient.Jump") end
          end
        end)
      end
    else
      caster:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_5, 1)
      if IsServer() then caster:EmitSound("Hero_ElderTitan.PreAttack") end
    end

    return true
  end

  function ancient_2__leap:OnAbilityPhaseInterrupted()
    local caster = self:GetCaster()
    caster:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
    caster:FadeGesture(ACT_DOTA_CAST_ABILITY_5)
    self.interruption = true
  end

  function ancient_2__leap:OnSpellStart()
    local caster = self:GetCaster()
    caster:Stop()

    caster:RemoveModifierByName("ancient_2_modifier_jump")
    caster:RemoveModifierByName("ancient_2_modifier_leap")

    self:SetCurrentAbilityCharges(self:GetCurrentAbilityCharges() + 1)

    if self:GetCastRange(nil, nil) > 0 then
      AddModifier(caster, caster, self, "ancient_2_modifier_jump", {}, false)
    else
      AddModifier(caster, caster, self, "ancient_2_modifier_leap", {}, false)
    end
  end

-- EFFECTS