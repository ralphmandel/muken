ancient_4_modifier_radiance_aura = class({})

function ancient_4_modifier_radiance_aura:IsHidden()
	return true
end

function ancient_4_modifier_radiance_aura:IsPurgable()
	return false
end

function ancient_4_modifier_radiance_aura:IsDebuff()
	return false
end

-- AURA -----------------------------------------------------------

function ancient_4_modifier_radiance_aura:IsAura()
	if self:GetParent():PassivesDisabled() then return false end
	return true
end

function ancient_4_modifier_radiance_aura:GetModifierAura()
	return "ancient_4_modifier_radiance_aura_effect"
end

function ancient_4_modifier_radiance_aura:GetAuraRadius()
	return self:GetAbility():GetAOERadius()
end

function ancient_4_modifier_radiance_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function ancient_4_modifier_radiance_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_4_modifier_radiance_aura:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function ancient_4_modifier_radiance_aura:OnRefresh(kv)
end

function ancient_4_modifier_radiance_aura:OnRemoved(kv)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function ancient_4_modifier_radiance_aura:GetEffectName()
	return "particles/econ/events/fall_2022/radiance/radiance_owner_fall2022.vpcf"
end

function ancient_4_modifier_radiance_aura:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end