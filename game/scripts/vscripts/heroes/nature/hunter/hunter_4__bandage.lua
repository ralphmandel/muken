hunter_4__bandage = class({})
LinkLuaModifier("hunter_4_modifier_channeling", "heroes/nature/hunter/hunter_4_modifier_channeling", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("hunter_4_modifier_bandage", "heroes/nature/hunter/hunter_4_modifier_bandage", LUA_MODIFIER_MOTION_NONE)

-- INIT

  function hunter_4__bandage:GetChannelTime()
    local channel = self:GetCaster():FindAbilityByName("_channel")
    local channel_time = self:GetSpecialValueFor("channel_time")
    return channel_time * (1 - (channel:GetLevel() * channel:GetSpecialValueFor("channel") * 0.01))
  end

-- SPELL START

	function hunter_4__bandage:OnSpellStart()
		local caster = self:GetCaster()
    self.target = self:GetCursorTarget()
    AddModifier(self.target, caster, self, "hunter_4_modifier_channeling", {}, false)
	end

  function hunter_4__bandage:OnChannelFinish(bInterrupted)
    if self.target == nil then return end
    self.target:RemoveModifierByName("hunter_4_modifier_channeling")

    if bInterrupted then
      self:EndCooldown()
      self:StartCooldown(1)
      return
    end

    local caster = self:GetCaster()

    self.target:Purge(false, true, false, true, false)

    AddModifier(self.target, caster, self, "hunter_4_modifier_bandage", {
      duration = self:GetSpecialValueFor("heal_duration")
    }, true)
	end

-- EFFECTS