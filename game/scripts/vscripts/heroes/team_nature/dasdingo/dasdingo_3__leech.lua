dasdingo_3__leech = class({})
LinkLuaModifier("dasdingo_3_modifier_passive", "heroes/team_nature/dasdingo/dasdingo_3_modifier_passive", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("dasdingo_3_modifier_leech", "heroes/team_nature/dasdingo/dasdingo_3_modifier_leech", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_modifier_stun", "modifiers/_modifier_stun", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function dasdingo_3__leech:OnOwnerSpawned()
    self:SetActivated(true)
  end

-- SPELL START

  function dasdingo_3__leech:OnAbilityPhaseStart()
    local caster = self:GetCaster()
    self.target = self:GetCursorTarget()

    local channel_time = CalcStatus(self:GetSpecialValueFor("channel_time"), caster, self.target)
    caster:FindAbilityByName("dasdingo__bind"):SetLevel(math.floor(channel_time * 100))

    return true
  end

  function dasdingo_3__leech:OnSpellStart()
    local caster = self:GetCaster()

    if self.target:TriggerSpellAbsorb(self) then
      caster:Interrupt()
    else
      AddModifier(self.target, caster, self, "dasdingo_3_modifier_leech", {duration = self:GetChannelTime()}, false)
      if IsServer() then self.target:EmitSound("Hero_ShadowShaman.Shackles.Cast") end
    end
  end

  function dasdingo_3__leech:OnChannelFinish(bInterrupted)
    local caster = self:GetCaster()
    if self.target then
      if IsValidEntity(self.target) then
        self.target:RemoveModifierByNameAndCaster("dasdingo_3_modifier_leech", caster)
      end
    end
  end

-- EFFECTS