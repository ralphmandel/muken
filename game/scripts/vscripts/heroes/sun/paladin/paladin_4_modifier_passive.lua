paladin_4_modifier_passive = class({})

function paladin_4_modifier_passive:IsHidden() return true end
function paladin_4_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function paladin_4_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then self:OnIntervalThink() end
end

function paladin_4_modifier_passive:OnRefresh(kv)
end

function paladin_4_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function paladin_4_modifier_passive:OnIntervalThink()
  local percent_required = self.ability:GetSpecialValueFor("damage_percent") * self.ability:GetSpecialValueFor("duration")
  self.ability:SetActivated(self.parent:GetHealthPercent() >= percent_required)
  if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------