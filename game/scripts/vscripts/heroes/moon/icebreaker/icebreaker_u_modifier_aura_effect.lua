icebreaker_u_modifier_aura_effect = class({})

function icebreaker_u_modifier_aura_effect:IsHidden() return false end
function icebreaker_u_modifier_aura_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker_u_modifier_aura_effect:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  self:ApplyBuff()

  if IsServer() then self:OnIntervalThink() end
end

function icebreaker_u_modifier_aura_effect:OnRefresh(kv)
end

function icebreaker_u_modifier_aura_effect:OnRemoved()
  RemoveStatusEfx(self.ability, "icebreaker_u_modifier_status_efx", self.caster, self.parent)
  RemoveBonus(self.ability, "RES", self.parent)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_bkb", self.ability)

  if self.parent:HasModifier("icebreaker__modifier_hypo") then
    AddModifier(self.parent, self.ability, "icebreaker__modifier_hypo", {stack = 0}, false)
  end
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker_u_modifier_aura_effect:OnIntervalThink()
  self:ApplyDebuff()
  if IsServer() then self:StartIntervalThink(0.1) end
end

-- UTILS -----------------------------------------------------------

function icebreaker_u_modifier_aura_effect:ApplyBuff()
  if self.parent:GetTeamNumber() ~= self.caster:GetTeamNumber() then return end
  AddStatusEfx(self.ability, "icebreaker_u_modifier_status_efx", self.caster, self.parent)
  AddBonus(self.ability, "RES", self.parent, self.ability:GetSpecialValueFor("res"), 0, nil)

  if self.ability:GetSpecialValueFor("special_immunity") == 1 and self.parent == self.caster then
    AddModifier(self.parent, self.ability, "_modifier_bkb", {}, false)
  end
end

function icebreaker_u_modifier_aura_effect:ApplyDebuff()
  if self.parent:GetTeamNumber() == self.caster:GetTeamNumber() then return end
  local mod = self.parent:FindModifierByName("icebreaker__modifier_hypo")
  local hypo_min_stack = self.ability:GetSpecialValueFor("hypo_min_stack")

  if mod == nil then
    mod = AddModifier(self.parent, self.ability, "icebreaker__modifier_hypo", {
      stack = hypo_min_stack
    }, false)
  elseif mod:GetStackCount() < hypo_min_stack then
    mod:SetStackCount(hypo_min_stack)
  end

  if mod:GetStackCount() == hypo_min_stack then
    mod:SetDuration(-1, true)
    mod.remaining_time = -1
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