icebreaker_u_modifier_aura_effect = class({})

function icebreaker_u_modifier_aura_effect:IsHidden() return false end
function icebreaker_u_modifier_aura_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_u_modifier_aura_effect:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  self:ApplyBuff()

  if IsServer() then self:StartIntervalThink(self.ability:GetSpecialValueFor("stack_interval")) end
end

function icebreaker_u_modifier_aura_effect:OnRefresh(kv)
end

function icebreaker_u_modifier_aura_effect:OnRemoved()
  RemoveStatusEfx(self.ability, "icebreaker_u_modifier_status_efx", self.caster, self.parent)
  RemoveBonus(self.ability, "RES", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_u_modifier_aura_effect:OnIntervalThink()
  self:ApplyDebuff()
  if IsServer() then self:StartIntervalThink(self.ability:GetSpecialValueFor("stack_interval")) end
end

-- UTILS -----------------------------------------------------------

function icebreaker_u_modifier_aura_effect:ApplyBuff()
  if self.parent:GetTeamNumber() ~= self.caster:GetTeamNumber() then return end
  AddStatusEfx(self.ability, "icebreaker_u_modifier_status_efx", self.caster, self.parent)
  AddBonus(self.ability, "RES", self.parent, self.ability:GetSpecialValueFor("res"), 0, nil)
end

function icebreaker_u_modifier_aura_effect:ApplyDebuff()
  if self.parent:GetTeamNumber() == self.caster:GetTeamNumber() then return end
  local mod = self.parent:FindModifierByName("icebreaker__modifier_hypo")
  local stack_min = self.ability:GetSpecialValueFor("stack_min")
  local increment = true

  if mod then
    if mod:GetStackCount() >= self.ability:GetSpecialValueFor("stack_min") then
      if IsServer() then mod:SetDuration(mod:GetRemainingTime() + self.ability:GetSpecialValueFor("stack_interval"), true) end
      increment = false
    end
  end

  if increment == true then
    AddModifier(self.parent, self.ability, "icebreaker__modifier_hypo", {stack = 1}, false)
  end
end

-- EFFECTS -----------------------------------------------------------

function icebreaker_u_modifier_aura_effect:GetStatusEffectName()
  if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
    return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_l2_radiant.vpcf"
  end
end

function icebreaker_u_modifier_aura_effect:StatusEffectPriority()
  if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
    return MODIFIER_PRIORITY_ULTRA
  end
end