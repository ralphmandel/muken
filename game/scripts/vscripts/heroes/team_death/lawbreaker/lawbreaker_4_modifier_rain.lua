lawbreaker_4_modifier_rain = class({})

function lawbreaker_4_modifier_rain:IsHidden() return true end
function lawbreaker_4_modifier_rain:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function lawbreaker_4_modifier_rain:IsAura() return true end
function lawbreaker_4_modifier_rain:GetModifierAura() return "lawbreaker_4_modifier_aura_effect" end
function lawbreaker_4_modifier_rain:GetAuraRadius() return self.radius end
function lawbreaker_4_modifier_rain:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function lawbreaker_4_modifier_rain:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function lawbreaker_4_modifier_rain:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end

-- CONSTRUCTORS -----------------------------------------------------------

function lawbreaker_4_modifier_rain:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.direction = (self.parent:GetOrigin() - self.caster:GetOrigin()):Normalized()
  self.radius = self.ability:GetAOERadius()
  
  if IsServer() then self:PlayEfxStart() end
end

function lawbreaker_4_modifier_rain:OnRefresh(kv)
end

function lawbreaker_4_modifier_rain:OnRemoved()
  if IsServer() then self:StopEfxStart() end
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function lawbreaker_4_modifier_rain:PlayEfxStart()
	local particle_cast = "particles/lawbreaker/rain/lawbreaker_rain.vpcf"
	self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(self.effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(self.radius, self.radius, 1 ))
  ParticleManager:SetParticleControlTransformForward(self.effect_cast, 2, self.parent:GetOrigin(), self.direction)

  AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), self.radius, self:GetDuration(), false)

  if IsServer() then self.parent:EmitSound("Hero_Sniper.MKG_ShrapnelShatter") end
end

function lawbreaker_4_modifier_rain:StopEfxStart()
  if self.effect_cast then
    ParticleManager:DestroyParticle(self.effect_cast, false)
    ParticleManager:ReleaseParticleIndex(self.effect_cast)
  end

  if IsServer() then self.parent:StopSound("Hero_Sniper.MKG_ShrapnelShatter") end
end