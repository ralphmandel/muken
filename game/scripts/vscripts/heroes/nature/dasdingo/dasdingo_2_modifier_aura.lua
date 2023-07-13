dasdingo_2_modifier_aura = class({})

function dasdingo_2_modifier_aura:IsHidden() return true end
function dasdingo_2_modifier_aura:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function dasdingo_2_modifier_aura:IsAura() return true end
function dasdingo_2_modifier_aura:GetModifierAura() return "dasdingo_2_modifier_aura_effect" end
function dasdingo_2_modifier_aura:GetAuraRadius() return self:GetAbility():GetAOERadius() end
function dasdingo_2_modifier_aura:GetAuraSearchTeam() return self:GetAbility():GetAbilityTargetTeam() end
function dasdingo_2_modifier_aura:GetAuraSearchType() return self:GetAbility():GetAbilityTargetType() end
function dasdingo_2_modifier_aura:GetAuraSearchFlags() return self:GetAbility():GetAbilityTargetFlags() end
function dasdingo_2_modifier_aura:GetAuraEntityReject(hEntity) return false end

-- CONSTRUCTORS -----------------------------------------------------------

function dasdingo_2_modifier_aura:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
end

function dasdingo_2_modifier_aura:OnRefresh(kv)
end

function dasdingo_2_modifier_aura:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------