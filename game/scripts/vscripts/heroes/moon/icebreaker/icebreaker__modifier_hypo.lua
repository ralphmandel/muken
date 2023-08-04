icebreaker__modifier_hypo = class({})

function icebreaker__modifier_hypo:IsHidden() return false end
function icebreaker__modifier_hypo:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker__modifier_hypo:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.last_applied_time = self:GetLastAppliedTime()
  self.remaining_time = -1
  self.intervals = 0.8

  AddStatusEfx(self.ability, "icebreaker__modifier_hypo_status_efx", self.caster, self.parent)
  self:CheckCounterEfx()

  if IsServer() then
    self:SetStackCount(kv.stack)
    self:StartIntervalThink(self.intervals)
  end
end

function icebreaker__modifier_hypo:OnRefresh(kv)
  if IsServer() then
    self:SetStackCount(self:GetStackCount() + kv.stack)
  end
end

function icebreaker__modifier_hypo:OnRemoved()
  if self.pidx then ParticleManager:DestroyParticle(self.pidx, true) end
  RemoveStatusEfx(self.ability, "icebreaker__modifier_hypo_status_efx", self.caster, self.parent)

  self.parent:RemoveModifierByNameAndCaster("_modifier_bat_increased", self.caster)
  self.parent:RemoveModifierByNameAndCaster("_modifier_percent_movespeed_debuff", self.caster)
  self.parent:RemoveModifierByNameAndCaster("_modifier_silence", self.caster)
  self.parent:RemoveModifierByNameAndCaster("_modifier_fear", self.caster)
end

function icebreaker__modifier_hypo:OnDestroy()
  self:CheckCounterEfx()
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker__modifier_hypo:OnIntervalThink()
  local blink = self.caster:FindAbilityByName("icebreaker_5__blink")

  if blink then
    if blink:IsTrained() then
      local hypo_damage = blink:GetSpecialValueFor("special_hypo_damage")
      if hypo_damage > 0 then
        ApplyDamage({
          victim = self.parent, attacker = self.caster, ability = blink,
          damage = hypo_damage * self.intervals,
          damage_type = DAMAGE_TYPE_MAGICAL
        })
      end    
    end
  end

  if IsServer() then self:StartIntervalThink(self.intervals) end
end

function icebreaker__modifier_hypo:OnStackCountChanged(old)
  if self:GetStackCount() > 0 then
    if IsServer() then
      local diff = self:GetStackCount() - old
      local increment_duration = CalcStatus(self.ability:GetSpecialValueFor("hypo_increment"), self.caster, self.parent) * diff

      if self.remaining_time == -1 then
        self.remaining_time = CalcStatus(self.ability:GetSpecialValueFor("hypo_duration"), self.caster, self.parent)
        self.last_applied_time = self:GetLastAppliedTime()
      end

      self.remaining_time = self.remaining_time - (self:GetLastAppliedTime() - self.last_applied_time)
      self.remaining_time = self.remaining_time + increment_duration
      self.last_applied_time = self:GetLastAppliedTime()
      self:SetDuration(self.remaining_time, true)
    end

    self.parent:RemoveModifierByNameAndCaster("_modifier_bat_increased", self.caster)
    AddModifier(self.parent, self.ability, "_modifier_bat_increased", {
      amount = self:GetStackCount() * self.ability:GetSpecialValueFor("hypo_as")
    }, false)

    RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_percent_movespeed_debuff", self.ability)
    AddModifier(self.parent, self.ability, "_modifier_percent_movespeed_debuff", {
      percent = self:GetStackCount() * self.ability:GetSpecialValueFor("hypo_ms")
    }, false)

    if IsServer() then self:PopupIce(self:GetStackCount() > old) end
  end

  if self:GetStackCount() >= self.ability:GetSpecialValueFor("max_hypo_stack") then
    AddModifier(self.parent, self.ability, "icebreaker__modifier_frozen", {
      duration = self.ability:GetSpecialValueFor("frozen_duration")
    }, true)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function icebreaker__modifier_hypo:GetStatusEffectName()
	return "particles/econ/items/drow/drow_ti9_immortal/status_effect_drow_ti9_frost_arrow.vpcf"
end

function icebreaker__modifier_hypo:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function icebreaker__modifier_hypo:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_curse_frostmourne_debuff.vpcf"
end

function icebreaker__modifier_hypo:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function icebreaker__modifier_hypo:CheckCounterEfx()
	local mod = self:GetParent():FindModifierByName("bocuse_3_modifier_sauce")
	if mod then
		if IsServer() then mod:PopupSauce(false) end
	end
end

function icebreaker__modifier_hypo:PopupIce(sound)
	if self.pidx then ParticleManager:DestroyParticle(self.pidx, true) end

	local particle = "particles/units/heroes/hero_drow/drow_hypothermia_counter_stack.vpcf"
  if self.parent:HasModifier("bocuse_3_modifier_sauce") then particle = "particles/icebreaker/icebreaker_counter_stack.vpcf" end
  self.pidx = ParticleManager:CreateParticle(particle, PATTACH_OVERHEAD_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.pidx, 1, Vector(0, self:GetStackCount(), 0))

	if sound == true then
		if IsServer() then self.parent:EmitSound("Hero_Icebreaker.Frost") end
	end
end