genuine_3_modifier_travel = class({})

function genuine_3_modifier_travel:IsHidden() return true end
function genuine_3_modifier_travel:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_3_modifier_travel:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  AddModifier(self.parent, self.caster, self.ability, "_modifier_ban", {}, false)

	if IsServer() then self:PlayEfxStart() end
end

function genuine_3_modifier_travel:OnRefresh(kv)
end

function genuine_3_modifier_travel:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_ban", self.ability)

  if IsServer() then self:PlayEfxEnd() end
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function genuine_3_modifier_travel:PlayEfxStart()
  local particle_cast = "particles/units/heroes/hero_puck/puck_illusory_orb_blink_out.vpcf"
  local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self.parent)
  ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
  ParticleManager:ReleaseParticleIndex(effect_cast)
end

function genuine_3_modifier_travel:PlayEfxEnd()
  local radius = self.ability:GetAOERadius()
  local particle_cast = "particles/genuine/genuine_travel_silence/genuine_silence_aproset.vpcf"
  local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, self.parent)
  ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
  ParticleManager:SetParticleControl(effect_cast, 1, Vector(radius, radius, radius))
  ParticleManager:ReleaseParticleIndex(effect_cast)

  if IsServer() then self.parent:EmitSound("Hero_Puck.Waning_Rift") end
end