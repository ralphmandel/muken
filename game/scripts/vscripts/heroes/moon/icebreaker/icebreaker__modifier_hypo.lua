icebreaker__modifier_hypo = class({})

function icebreaker__modifier_hypo:IsHidden() return false end
function icebreaker__modifier_hypo:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker__modifier_hypo:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  AddStatusEfx(self.ability, "icebreaker__modifier_hypo_status_efx", self.caster, self.parent)

  self:CheckCounterEfx()

  if IsServer() then
    local duration = CalcStatus(self.ability:GetSpecialValueFor("hypo_duration") * kv.stack, self.caster, self.parent)
    self:SetDuration(duration, true)
    self:SetStackCount(kv.stack)
    self.die_time = self:GetDieTime()

    local shard_aura = self.parent:FindModifierByName("icebreaker_u_modifier_aura_effect")
    if shard_aura then shard_aura:StartIntervalThink(shard_aura:GetAbility():GetSpecialValueFor("stack_interval")) end
  end
end

function icebreaker__modifier_hypo:OnRefresh(kv)
  if IsServer() then
    local duration = CalcStatus(self.ability:GetSpecialValueFor("hypo_duration") * kv.stack, self.caster, self.parent)
    duration = self.die_time - GameRules:GetGameTime() + duration
    self:SetDuration(duration, true)
    self:SetStackCount(self:GetStackCount() + kv.stack)
    self.die_time = self:GetDieTime()

    local shard_aura = self.parent:FindModifierByName("icebreaker_u_modifier_aura_effect")
    if shard_aura then shard_aura:StartIntervalThink(shard_aura:GetAbility():GetSpecialValueFor("stack_interval")) end
  end
end

function icebreaker__modifier_hypo:OnRemoved()
  if self.pidx then ParticleManager:DestroyParticle(self.pidx, true) end
  self.parent:RemoveModifierByName("icebreaker__modifier_slow")
  RemoveStatusEfx(self.ability, "icebreaker__modifier_hypo_status_efx", self.caster, self.parent)
end

function icebreaker__modifier_hypo:OnDestroy()
  self:CheckCounterEfx()
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker__modifier_hypo:OnStackCountChanged(old)
  if self:GetStackCount() > 0 then
    if IsServer() then self:PopupIce(self:GetStackCount() > old) end
  end

  local max_stack = self.ability:GetSpecialValueFor("max_hypo_stack")
  local stack = self:GetStackCount() - old

  if self:GetStackCount() >= max_stack then
    AddModifier(self.parent, self.ability, "icebreaker__modifier_frozen", {
      duration = self.ability:GetSpecialValueFor("frozen_duration"),
      stack = self:GetStackCount() - max_stack
    }, true)
    return
	end

  if stack > 0 then
    AddModifier(self.parent, self.ability, "icebreaker__modifier_slow", {
      duration = self.ability:GetSpecialValueFor("slow_duration") * stack, stack = self:GetStackCount()
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