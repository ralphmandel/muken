templar_3_modifier_circle = class({})

function templar_3_modifier_circle:IsHidden() return true end
function templar_3_modifier_circle:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function templar_3_modifier_circle:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.radius = self.ability:GetAOERadius()
  
  if IsServer() then
    self:StartIntervalThink(self.ability:GetSpecialValueFor("interval"))
    self:PlayEfxStart()
  end
end

function templar_3_modifier_circle:OnRefresh(kv)
end

function templar_3_modifier_circle:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function templar_3_modifier_circle:OnRemoved()
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function templar_3_modifier_circle:PlayEfxStart()
	local particle_cast = "particles/units/heroes/hero_oracle/oracle_scepter_rain_of_destiny.vpcf"
	self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(self.radius, self.radius, self.radius))
	self:AddParticle(self.effect_cast, false, false, -1, true, false)

  if IsServer() then self.parent:EmitSound("Hero_Oracle.RainOfDestiny") end
end