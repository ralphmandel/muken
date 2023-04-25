druid_u_modifier_aura = class({})

function druid_u_modifier_aura:IsHidden() return true end
function druid_u_modifier_aura:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function druid_u_modifier_aura:IsAura() return true end
function druid_u_modifier_aura:GetModifierAura() return "druid_u_modifier_aura_effect" end
function druid_u_modifier_aura:GetAuraRadius() return self:GetAbility():GetAOERadius() end

function druid_u_modifier_aura:GetAuraSearchTeam()
  if self:GetAbility():GetSpecialValueFor("special_str") > 0
  or self:GetAbility():GetSpecialValueFor("special_agi") > 0 then
    return DOTA_UNIT_TARGET_TEAM_BOTH
  end
  
  return self:GetAbility():GetAbilityTargetTeam()
end

function druid_u_modifier_aura:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function druid_u_modifier_aura:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end
function druid_u_modifier_aura:GetAuraEntityReject(hEntity)
  if self:GetAbility():GetSpecialValueFor("special_str") > 0
  or self:GetAbility():GetSpecialValueFor("special_agi") > 0
  or self:GetAbility():GetSpecialValueFor("special_slow") > 0
  or self:GetAbility():GetSpecialValueFor("special_manaloss") > 0 then
    return false
  end
  return hEntity:IsHero()
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_u_modifier_aura:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	if IsServer() then
    self:PlayEfxStart()
    self:StartIntervalThink(3)
  end
end

function druid_u_modifier_aura:OnRefresh(kv)
end

function druid_u_modifier_aura:OnRemoved()
  if self.efx_channel then ParticleManager:DestroyParticle(self.efx_channel, false) end
  if self.efx_channel2 then ParticleManager:DestroyParticle(self.efx_channel2, false) end
	if self.fow then RemoveFOWViewer(self.parent:GetTeamNumber(), self.fow) end
	if IsServer() then self.parent:StopSound("Druid.Channel") end
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_u_modifier_aura:OnIntervalThink()
  if self.fow then RemoveFOWViewer(self.parent:GetTeamNumber(), self.fow) end
	self.fow = AddFOWViewer(self.parent:GetTeamNumber(), self.ability.point, self.ability:GetAOERadius(), 3, true)

  if self.efx_channel2 then
    ParticleManager:SetParticleControl(self.efx_channel2, 5, Vector(math.floor(self.ability:GetAOERadius() * 0.1), 0, 0))
  end

	if IsServer() then
    self.parent:EmitSound("Druid.Channel")
    self:StartIntervalThink(3)
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function druid_u_modifier_aura:PlayEfxStart()
	self.efx_channel = ParticleManager:CreateParticle("particles/druid/druid_skill1_channeling.vpcf", PATTACH_ABSORIGIN, self.parent)
	ParticleManager:SetParticleControl(self.efx_channel, 0, self.parent:GetOrigin())

	self.efx_channel2 = ParticleManager:CreateParticle("particles/druid/druid_skill1_channeling.vpcf", PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(self.efx_channel2, 0, self.ability.point)
	ParticleManager:SetParticleControl(self.efx_channel2, 5, Vector(math.floor(self.ability:GetAOERadius() * 0.1), 0, 0))

  if IsServer() then self.parent:EmitSound("Druid.Channel") end
end