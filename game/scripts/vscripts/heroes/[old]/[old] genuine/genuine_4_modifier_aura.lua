genuine_4_modifier_aura = class({})

function genuine_4_modifier_aura:IsHidden() return true end
function genuine_4_modifier_aura:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function genuine_4_modifier_aura:IsAura() return self:GetParent():PassivesDisabled() == false end
function genuine_4_modifier_aura:GetModifierAura() return "genuine_4_modifier_aura_effect" end
function genuine_4_modifier_aura:GetAuraRadius() return self:GetAbility():GetAOERadius() end
function genuine_4_modifier_aura:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function genuine_4_modifier_aura:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function genuine_4_modifier_aura:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_4_modifier_aura:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
end

function genuine_4_modifier_aura:OnRefresh(kv)
end

function genuine_4_modifier_aura:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function genuine_4_modifier_aura:GetEffectName()
	return "particles/econ/events/diretide_2020/emblem/fall20_emblem_v2_effect.vpcf"
end

function genuine_4_modifier_aura:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end