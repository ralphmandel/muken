dasdingo_1_modifier_aura_effect = class({})

function dasdingo_1_modifier_aura_effect:IsHidden() return true end
function dasdingo_1_modifier_aura_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function dasdingo_1_modifier_aura_effect:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  self.interval = self.ability:GetSpecialValueFor("interval")

  if IsServer() then self:StartIntervalThink(self.interval) end
end

function dasdingo_1_modifier_aura_effect:OnRefresh(kv)
end

function dasdingo_1_modifier_aura_effect:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function dasdingo_1_modifier_aura_effect:OnIntervalThink()
  self.parent:Heal(CalcHeal(self.caster, self.ability:GetSpecialValueFor("heal_tick")), self.ability)
  
  if IsServer() then
    self:PlayEfxHeal()
    self:StartIntervalThink(self.interval)
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function dasdingo_1_modifier_aura_effect:PlayEfxHeal()
	local particle = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect_parent = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_parent, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_parent)
end