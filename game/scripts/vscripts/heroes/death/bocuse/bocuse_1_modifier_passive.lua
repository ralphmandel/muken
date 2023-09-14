bocuse_1_modifier_passive = class({})

function bocuse_1_modifier_passive:IsHidden() return true end
function bocuse_1_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_1_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then self:OnIntervalThink() end
end

function bocuse_1_modifier_passive:OnRefresh(kv)
end

function bocuse_1_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_1_modifier_passive:OnIntervalThink()
  local isCutting = self.parent:HasModifier("bocuse_1_modifier_julienne")
  local hasMinCharges = self.ability:GetCurrentAbilityCharges() >= self.ability:GetSpecialValueFor("min_cut")
  self.ability:SetActivated(hasMinCharges == true and isCutting == false)

  if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------