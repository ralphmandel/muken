druid_5_modifier_aura = class({})

function druid_5_modifier_aura:IsHidden() return false end
function druid_5_modifier_aura:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function druid_5_modifier_aura:IsAura() return self:GetParent():PassivesDisabled() == false end
function druid_5_modifier_aura:GetModifierAura() return "druid_5_modifier_aura_effect" end
function druid_5_modifier_aura:GetAuraRadius() return self:GetAbility():GetAOERadius() end
function druid_5_modifier_aura:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function druid_5_modifier_aura:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function druid_5_modifier_aura:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end
function druid_5_modifier_aura:GetAuraEntityReject(hEntity) return (self:GetParent() == hEntity) end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_5_modifier_aura:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
  self.interval = 0.3

  if IsServer() then
    self:PlayEfxStart()
    self:StartIntervalThink(self.interval)
  end
end

function druid_5_modifier_aura:OnRefresh(kv)
end

function druid_5_modifier_aura:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_5_modifier_aura:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_CAN_ATTACK_TREES,
		MODIFIER_PROPERTY_EXTRA_MANA_PERCENTAGE
	}

	return funcs
end

-- function druid_5_modifier_aura:GetModifierCanAttackTrees()
--   return 1
-- end

function druid_5_modifier_aura:GetModifierExtraManaPercentage(keys)
  return self:GetAbility():GetSpecialValueFor("mana_reduction")
end

function druid_5_modifier_aura:OnIntervalThink()
  local radius = self.ability:GetAOERadius()
  local trees = GridNav:GetAllTreesAroundPoint(self.parent:GetOrigin(), radius, false)

  if trees then
    for _,tree in pairs(trees) do
      if RandomFloat(1, 100) <= self.ability:GetSpecialValueFor("tree_chance") * self.interval then
        self.ability:CreateSeed(tree)
      end
    end
  end

  if self.effect_aura then ParticleManager:SetParticleControl(self.effect_aura, 1, Vector(radius, 0, 0)) end
  if IsServer() then self:StartIntervalThink(self.interval) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function druid_5_modifier_aura:PlayEfxStart()
	local string_3 = "particles/druid/druid_ult_passive.vpcf"
	self.effect_aura = ParticleManager:CreateParticle(string_3, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_aura, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_aura, 1, Vector(self.ability:GetAOERadius(), 0, 0))
	self:AddParticle(self.effect_aura, false, false, -1, false, false)
end