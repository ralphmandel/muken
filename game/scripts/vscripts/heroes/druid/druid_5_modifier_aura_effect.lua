druid_5_modifier_aura_effect = class({})

function druid_5_modifier_aura_effect:IsHidden() return false end
function druid_5_modifier_aura_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_5_modifier_aura_effect:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.delay = false
  self.amount = 0
end

function druid_5_modifier_aura_effect:OnRefresh(kv)
end

function druid_5_modifier_aura_effect:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_5_modifier_aura_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function druid_5_modifier_aura_effect:OnTakeDamage(keys)
  if keys.unit ~= self.parent then return end
  if self.delay == true then return end

  self.amount = self.amount + keys.damage
  local amount_required = self.parent:GetBaseMaxHealth() * self.ability:GetSpecialValueFor("hp_percent") * 0.01

  if self.amount >= amount_required then
    self.amount = 0
    self.delay = true
    self:PlayEfxSeed()
    self:CreateSeed()
    if IsServer() then self:StartIntervalThink(self.ability:GetSpecialValueFor("delay")) end
  end
end

function druid_5_modifier_aura_effect:OnIntervalThink()
  self.delay = false
  if IsServer() then self:StartIntervalThink(-1) end
end

-- UTILS -----------------------------------------------------------

function druid_5_modifier_aura_effect:CreateSeed()
  local seed_base_heal = self.ability:GetSpecialValueFor("seed_base_heal")

  ProjectileManager:CreateTrackingProjectile({
    Target = self.caster,
    Source = self.parent,
    Ability = self.ability,
    EffectName = "particles/druid/druid_ult_projectile.vpcf",
    iSourceAttachment = DOTA_PROJECTILE_ATTACHMENT_HITLOCATION,
    iMoveSpeed = self.ability:GetSpecialValueFor("seed_speed"),
    bReplaceExisting = false,
    bProvidesVision = true,
    iVisionRadius = 75,
    iVisionTeamNumber = self.caster:GetTeamNumber(),
    ExtraData = {amount = seed_base_heal + ((seed_base_heal / 5) * self.parent:GetLevel())}
  })
end

-- EFFECTS -----------------------------------------------------------

function druid_5_modifier_aura_effect:PlayEfxSeed()
	local string = "particles/units/heroes/hero_treant/treant_leech_seed_damage_pulse.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle)

	if IsServer() then self.parent:EmitSound("Hero_Treant.LeechSeed.Tick") end
end