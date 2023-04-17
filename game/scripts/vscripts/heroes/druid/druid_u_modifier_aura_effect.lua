druid_u_modifier_aura_effect = class({})

function druid_u_modifier_aura_effect:IsHidden() return true end
function druid_u_modifier_aura_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_u_modifier_aura_effect:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	self.interval = self.ability:GetSpecialValueFor("interval")
  self.ability:SetCurrentAbilityCharges(self.ability:GetCurrentAbilityCharges() + 1)

  if IsServer() then
    self:PlayEfxStart()
    self:StartIntervalThink(self.interval)
  end
end

function druid_u_modifier_aura_effect:OnRefresh(kv)
end

function druid_u_modifier_aura_effect:OnRemoved()
  self.ability:SetCurrentAbilityCharges(self.ability:GetCurrentAbilityCharges() - 1)
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_u_modifier_aura_effect:OnIntervalThink()
  local calc = (100 / (10 + self.parent:GetLevel())) * (1 + (self.caster:GetLevel() * self.ability:GetSpecialValueFor("chance") * 0.01))
  if RandomFloat(1, 100) <= calc * self.interval and self.parent:GetLevel() <= self.ability:GetSpecialValueFor("max_dominate") then
    self.parent:Purge(false, true, false, false, false)
    self.parent:AddNewModifier(self.caster, self.ability, "druid_u_modifier_conversion", {})    
    self:Destroy()
    return
  end

	if IsServer() then self:StartIntervalThink(self.interval) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function druid_u_modifier_aura_effect:PlayEfxStart()
	local string_3 = "particles/units/heroes/hero_enchantress/enchantress_enchant_slow.vpcf"
	local particle = ParticleManager:CreateParticle(string_3, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	self:AddParticle(particle, false, false, -1, false, false)
end