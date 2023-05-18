ancient_2_modifier_charges = class({})

function ancient_2_modifier_charges:IsHidden() return false end
function ancient_2_modifier_charges:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_2_modifier_charges:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then self:SetStackCount(0) end
end

function ancient_2_modifier_charges:OnRefresh(kv)
end

function ancient_2_modifier_charges:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_2_modifier_charges:OnStackCountChanged(old)
  if self:GetStackCount() == 0 then
    self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
    if IsServer() then self:SetStackCount(self.ability:GetSpecialValueFor("hits")) end
  end
end


-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------