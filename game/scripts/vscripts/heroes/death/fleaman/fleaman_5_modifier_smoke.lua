fleaman_5_modifier_smoke = class({})

function fleaman_5_modifier_smoke:IsHidden() return true end
function fleaman_5_modifier_smoke:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function fleaman_5_modifier_smoke:IsAura() return true end
function fleaman_5_modifier_smoke:GetModifierAura() return "fleaman_5_modifier_aura_effect" end
function fleaman_5_modifier_smoke:GetAuraRadius() return self.radius end
function fleaman_5_modifier_smoke:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function fleaman_5_modifier_smoke:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function fleaman_5_modifier_smoke:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end
function fleaman_5_modifier_smoke:GetAuraEntityReject(hEntity)
  if hEntity:GetTeamNumber() == self:GetCaster():GetTeamNumber() and hEntity ~= self:GetCaster() then return true end
  return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function fleaman_5_modifier_smoke:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.radius = self.ability:GetAOERadius()

	if IsServer() then self:PlayEfxStart(self.radius) end
end

function fleaman_5_modifier_smoke:OnRefresh(kv)
end

function fleaman_5_modifier_smoke:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function fleaman_5_modifier_smoke:PlayEfxStart()
	local string_2 = "particles/fleaman/smoke/fleaman_smoke.vpcf"
	local particle_2 = ParticleManager:CreateParticle(string_2, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(particle_2, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(particle_2, 1, Vector(self.radius, self.radius, self.radius))
	ParticleManager:SetParticleControl(particle_2, 10, Vector(self:GetDuration(), 0, 0))
	self:AddParticle(particle_2, false, false, -1, false, false)

  AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), self.radius, self:GetDuration() + 1, false)

	if IsServer() then self.parent:EmitSound("Hero_Riki.Smoke_Screen.ti8") end
end