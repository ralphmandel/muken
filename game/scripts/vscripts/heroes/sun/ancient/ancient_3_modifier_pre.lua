ancient_3_modifier_pre = class({})

function ancient_3_modifier_pre:IsHidden() return true end
function ancient_3_modifier_pre:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_3_modifier_pre:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then self:StartIntervalThink(0.5) end
end

function ancient_3_modifier_pre:OnRefresh(kv)
end

function ancient_3_modifier_pre:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_3_modifier_pre:OnIntervalThink()
  if IsServer() then
    self:PlayEfxPre()
    self:StartIntervalThink(-1)
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function ancient_3_modifier_pre:PlayEfxPre()
  local particle_shake = "particles/osiris/poison_alt/osiris_poison_splash_shake.vpcf"
	local effect = ParticleManager:CreateParticle(particle_shake, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(effect, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect, 1, Vector(500, 0, 0))

  if IsServer() then self.parent:EmitSound("Hero_PrimalBeast.GroundPound.Loud")end
end