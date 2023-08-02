templar_1_modifier_aura = class({})

function templar_1_modifier_aura:IsHidden() return true end
function templar_1_modifier_aura:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function templar_1_modifier_aura:IsAura() return true end
function templar_1_modifier_aura:GetModifierAura() return "templar_1_modifier_aura_effect" end
function templar_1_modifier_aura:GetAuraRadius() return self:GetAbility():GetAOERadius() end
function templar_1_modifier_aura:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function templar_1_modifier_aura:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function templar_1_modifier_aura:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end

-- CONSTRUCTORS -----------------------------------------------------------

function templar_1_modifier_aura:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function templar_1_modifier_aura:OnRefresh(kv)
end

function templar_1_modifier_aura:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------