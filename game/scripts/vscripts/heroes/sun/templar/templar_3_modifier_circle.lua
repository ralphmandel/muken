templar_3_modifier_circle = class({})

function templar_3_modifier_circle:IsHidden() return true end
function templar_3_modifier_circle:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function templar_3_modifier_circle:IsAura() return true end
function templar_3_modifier_circle:GetModifierAura() return "templar_3_modifier_aura_effect" end
function templar_3_modifier_circle:GetAuraRadius() return self.radius end
function templar_3_modifier_circle:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function templar_3_modifier_circle:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function templar_3_modifier_circle:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end

-- CONSTRUCTORS -----------------------------------------------------------

function templar_3_modifier_circle:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.radius = self.ability:GetAOERadius()
  
  if IsServer() then self:PlayEfxStart() end
end

function templar_3_modifier_circle:OnRefresh(kv)
end

function templar_3_modifier_circle:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function templar_3_modifier_circle:PlayEfxStart()
	local particle_cast = "particles/templar/circle/templar_circle_pit.vpcf"
	self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(self.radius, 1, 1))
	ParticleManager:SetParticleControl(self.effect_cast, 2, Vector(self:GetDuration(), 0, 0))
	--self:AddParticle(self.effect_cast, false, false, -1, true, false)

  if IsServer() then
    self.parent:EmitSound("Hero_AbyssalUnderlord.PitOfMalice.Start")
    self.parent:EmitSound("Hero_Oracle.RainOfDestiny")
  end
end