priest_2_modifier_aura = class({})

function priest_2_modifier_aura:IsHidden() return true end
function priest_2_modifier_aura:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function priest_2_modifier_aura:IsAura() return true end
function priest_2_modifier_aura:GetModifierAura() return "priest_2_modifier_aura_effect" end
function priest_2_modifier_aura:GetAuraRadius() return self:GetAbility():GetAOERadius() end
function priest_2_modifier_aura:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function priest_2_modifier_aura:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function priest_2_modifier_aura:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end
function priest_2_modifier_aura:GetAuraEntityReject(hEntity) return false end

-- CONSTRUCTORS -----------------------------------------------------------

function priest_2_modifier_aura:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
end

function priest_2_modifier_aura:OnRefresh(kv)
end

function priest_2_modifier_aura:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------