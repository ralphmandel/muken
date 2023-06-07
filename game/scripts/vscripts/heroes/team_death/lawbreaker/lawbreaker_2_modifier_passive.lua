lawbreaker_2_modifier_passive = class({})

function lawbreaker_2_modifier_passive:IsHidden() return false end
function lawbreaker_2_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function lawbreaker_2_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then
    self:SetStackCount(0)
    self:StartIntervalThink(self.ability:GetSpecialValueFor("recharge_time"))
  end
end

function lawbreaker_2_modifier_passive:OnRefresh(kv)
end

function lawbreaker_2_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function lawbreaker_2_modifier_passive:OnIntervalThink()
  if IsServer() then
    self:IncrementStackCount()
    self:StartIntervalThink(self.ability:GetSpecialValueFor("recharge_time"))
  end
end

function lawbreaker_2_modifier_passive:OnStackCountChanged(old)
  self.ability:SetActivated(self:GetStackCount() >= self.ability:GetSpecialValueFor("min_shots"))
  if self:GetStackCount() == 0 then self.parent:RemoveModifierByName("lawbreaker_2_modifier_combo") end

  if self:GetStackCount() > self.ability:GetSpecialValueFor("max_shots") then
    if IsServer() then self:SetStackCount(self.ability:GetSpecialValueFor("max_shots")) end
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------