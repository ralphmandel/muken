lawbreaker_u_modifier_sequence = class({})

function lawbreaker_u_modifier_sequence:IsHidden() return false end
function lawbreaker_u_modifier_sequence:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function lawbreaker_u_modifier_sequence:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then
    self:StartIntervalThink(self:OnIntervalThink())
  end
end

function lawbreaker_u_modifier_sequence:OnRefresh(kv)
end

function lawbreaker_u_modifier_sequence:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------


function lawbreaker_u_modifier_sequence:OnIntervalThink()
  print("kubito", self.parent:GetSequence())
  if IsServer() then self:StartIntervalThink(FrameTime()) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------