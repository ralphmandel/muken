dasdingo_2_modifier_aura = class({})

function dasdingo_2_modifier_aura:IsHidden()
	return true
end

function dasdingo_2_modifier_aura:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function dasdingo_2_modifier_aura:IsAura()
	if self:GetParent():PassivesDisabled() then return false end
	if self:GetParent():IsIllusion() then return false end
	return true
end

function dasdingo_2_modifier_aura:GetModifierAura()
	return "dasdingo_2_modifier_aura_effect"
end

function dasdingo_2_modifier_aura:GetAuraRadius()
	if self:GetAbility():GetCurrentAbilityCharges() == 0 then return self:GetAbility():GetSpecialValueFor("radius") end
	if self:GetAbility():GetCurrentAbilityCharges() == 1 then return self:GetAbility():GetSpecialValueFor("radius") end
	if self:GetAbility():GetCurrentAbilityCharges() % 2 == 0 then return self:GetAbility():GetSpecialValueFor("radius") * 1.4 end
end

function dasdingo_2_modifier_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_FRIENDLY
end

function dasdingo_2_modifier_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO
end