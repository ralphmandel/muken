genuine_2_modifier_fallen = class({})

function genuine_2_modifier_fallen:IsHidden() return true end
function genuine_2_modifier_fallen:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_2_modifier_fallen:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  AddModifier(self.parent, self.ability, "_modifier_fear", {special = 1}, false)

  if IsServer() then self:PlayEfxStart() end
end

function genuine_2_modifier_fallen:OnRefresh(kv)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_fear", self.ability)
  AddModifier(self.parent, self.ability, "_modifier_fear", {special = 1}, false)

  if IsServer() then self:PlayEfxStart() end
end

function genuine_2_modifier_fallen:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_fear", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function genuine_2_modifier_fallen:PlayEfxStart()
  local particle_cast = "particles/genuine/genuine_fallen_hit.vpcf"
  local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
  ParticleManager:ReleaseParticleIndex(effect_cast)
end