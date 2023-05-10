icebreaker__modifier_hypo = class({})

function icebreaker__modifier_hypo:IsHidden() return false end
function icebreaker__modifier_hypo:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker__modifier_hypo:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  AddStatusEfx(self.ability, "icebreaker__modifier_hypo_status_efx", self.caster, self.parent)
  self:CheckCounterEfx()

  local stack = kv.stack

  local blink = self.caster:FindAbilityByName("icebreaker_5__blink")
  if blink then
    if blink:IsTrained() then
      local hypo_damage = blink:GetSpecialValueFor("special_hypo_damage")
      if hypo_damage > 0 then
        self.parent:AddNewModifier(self.caster, blink, "icebreaker__modifier_hypo_dps", {hypo_damage = hypo_damage})
      end     
    end
  end

  if IsServer() then
    self:SetStackCount(stack)
    self:StartIntervalThink(CalcStatus(self.ability:GetSpecialValueFor("hypo_decay"), self.caster, self.parent))
  end
end

function icebreaker__modifier_hypo:OnRefresh(kv)
  local stack = kv.stack

  if IsServer() then
    self:SetStackCount(self:GetStackCount() + stack)
  end
end

function icebreaker__modifier_hypo:OnRemoved()
  if self.pidx then ParticleManager:DestroyParticle(self.pidx, true) end
  RemoveStatusEfx(self.ability, "icebreaker__modifier_hypo_status_efx", self.caster, self.parent)
  BaseStats(self.parent):SetBaseAttackTime(0)

  self.parent:RemoveModifierByNameAndCaster("_modifier_percent_movespeed_debuff", self.caster)
  self.parent:RemoveModifierByNameAndCaster("icebreaker__modifier_hypo_dps", self.caster)
end

function icebreaker__modifier_hypo:OnDestroy()
  self:CheckCounterEfx()
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker__modifier_hypo:OnIntervalThink()
  if IsServer() then
    self:DecrementStackCount()
    self:StartIntervalThink(CalcStatus(self.ability:GetSpecialValueFor("hypo_decay"), self.caster, self.parent))
  end
end

function icebreaker__modifier_hypo:OnStackCountChanged(old)
  if self:GetStackCount() ~= old then
    if self:GetStackCount() == 0 then self:Destroy() return end

    BaseStats(self.parent):SetBaseAttackTime(self:GetStackCount() * self.ability:GetSpecialValueFor("hypo_as"))
    RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_percent_movespeed_debuff", self.ability)

    self.parent:AddNewModifier(self.caster, self.ability, "_modifier_percent_movespeed_debuff", {
			percent = self:GetStackCount() * self.ability:GetSpecialValueFor("hypo_ms")
		})

    if IsServer() then self:PopupIce(self:GetStackCount() > old) end
  end

  if self:GetStackCount() >= self.ability:GetSpecialValueFor("max_hypo_stack") then
		self.parent:AddNewModifier(self.caster, self.ability, "icebreaker__modifier_frozen", {
			duration = CalcStatus(self.ability:GetSpecialValueFor("frozen_duration"), self.caster, self.parent)
		})
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