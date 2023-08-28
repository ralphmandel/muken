lawbreaker_1_modifier_passive = class({})

function lawbreaker_1_modifier_passive:IsHidden() return false end
function lawbreaker_1_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function lawbreaker_1_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.gunslinger = self.parent:AddAbility("muerta_gunslinger")
  self.gunslinger:SetCurrentAbilityCharges(0)
  self.gunslinger:UpgradeAbility(true)
  self.gunslinger:SetHidden(true)

  if IsServer() then self:SetStackCount(0) end
end

function lawbreaker_1_modifier_passive:OnRefresh(kv)
end

function lawbreaker_1_modifier_passive:OnRemoved()
	
end

-- API FUNCTIONS -----------------------------------------------------------

function lawbreaker_1_modifier_passive:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_PROJECTILE_NAME,
    MODIFIER_EVENT_ON_ATTACK_START,
    MODIFIER_EVENT_ON_ATTACKED,
	}

	return funcs
end

function lawbreaker_1_modifier_passive:GetModifierProjectileName()
  if self:GetStackCount() >= self:GetAbility():GetSpecialValueFor("max_hit") - 1 then
    return "particles/units/heroes/hero_muerta/muerta_base_attack_alt.vpcf"
  end
end

function lawbreaker_1_modifier_passive:OnAttackStart(keys)
  if keys.attacker ~= self.parent then return end

  if self.parent:PassivesDisabled() == false and self:GetStackCount() == self.ability:GetSpecialValueFor("max_hit") - 1 then
    self.gunslinger:SetCurrentAbilityCharges(1)
  else
    self.gunslinger:SetCurrentAbilityCharges(0)
  end

  self.gunslinger:SetLevel(1)
end

function lawbreaker_1_modifier_passive:OnAttacked(keys)
  if keys.attacker ~= self.parent then return end

  if self.parent:PassivesDisabled() == false and self:GetStackCount() >= self.ability:GetSpecialValueFor("max_hit") - 1 then
    local heal = keys.original_damage * self.ability:GetSpecialValueFor("lifesteal") * 0.01
    self.parent:Heal(heal, self.ability)
    self:PlayEfxLifesteal(keys.attacker)
  end

  if IsServer() then self:IncrementStackCount() end
end

function lawbreaker_1_modifier_passive:OnStackCountChanged(old)
  local double = 1
  if self.parent:HasModifier("lawbreaker_2_modifier_combo") then double = 0 end

  if self:GetStackCount() >= self.ability:GetSpecialValueFor("max_hit") + double then 
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

  if IsServer() then target:EmitSound("Hero_Muerta.PartingShot.Start") end
end