lawbreaker_1_modifier_passive = class({})

function lawbreaker_1_modifier_passive:IsHidden() return false end
function lawbreaker_1_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function lawbreaker_1_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then self:SetStackCount(0) end
end

function lawbreaker_1_modifier_passive:OnRefresh(kv)
end

function lawbreaker_1_modifier_passive:OnRemoved()
	
end

-- API FUNCTIONS -----------------------------------------------------------

function lawbreaker_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
    MODIFIER_EVENT_ON_ATTACKED
	}

	return funcs
end

function lawbreaker_1_modifier_passive:OnAttacked(keys)
  if keys.attacker ~= self.parent then return end
  if self.parent:PassivesDisabled() then return end
  if IsServer() then self:IncrementStackCount() end

  if self:GetStackCount() == self.ability:GetSpecialValueFor("max_hit") - 1 then
    BaseStats(self.parent):SetForceCrit(100, BaseStats(self.parent):GetTotalCriticalDamage() + self.ability:GetSpecialValueFor("crit_dmg"))
  end

  if self:GetStackCount() == 0 then
    local heal = keys.original_damage * self.ability:GetSpecialValueFor("lifesteal") * 0.01
    self.parent:Heal(heal, self.ability)
    self:PlayEfxLifesteal(keys.attacker)
  end
end

function lawbreaker_1_modifier_passive:OnStackCountChanged(old)
  if self:GetStackCount() == self.ability:GetSpecialValueFor("max_hit") then 
    if IsServer() then self:SetStackCount(0) end
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function lawbreaker_1_modifier_passive:PlayEfxLifesteal(target)
	local particle = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, target)
	ParticleManager:SetParticleControl(effect, 1, target:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect)
end