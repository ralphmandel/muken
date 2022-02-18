crusader_u_modifier_aura = class({})

function crusader_u_modifier_aura:IsHidden()
	return true
end

function crusader_u_modifier_aura:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Aura

function crusader_u_modifier_aura:IsAura()
	return (not self:GetCaster():PassivesDisabled())
end

function crusader_u_modifier_aura:GetModifierAura()
	return "crusader_u_modifier_aura_effect"
end

function crusader_u_modifier_aura:GetAuraRadius()
	return self:GetAbility():GetRadius()
end

function crusader_u_modifier_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function crusader_u_modifier_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end