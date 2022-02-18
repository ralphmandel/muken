icebreaker_u_modifier_degen = class({})

function icebreaker_u_modifier_degen:IsHidden()
	return true
end

function icebreaker_u_modifier_degen:IsPurgable()
    return false
end

function icebreaker_u_modifier_degen:IsDebuff()
	return true
end

----------------------------------------------------------------------------

function icebreaker_u_modifier_degen:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
end

function icebreaker_u_modifier_degen:OnRefresh( kv )
end

function icebreaker_u_modifier_degen:OnRemoved()
end

----------------------------------------------------------------------------

function icebreaker_u_modifier_degen:DeclareFunctions()

    local funcs = {
        MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE
    }
    return funcs
end

function icebreaker_u_modifier_degen:GetModifierHealAmplify_PercentageTarget()
    return -50
end

function icebreaker_u_modifier_degen:GetModifierHPRegenAmplify_Percentage(keys)
    return -50
end

----------------------------------------------------------------------------

function icebreaker_u_modifier_degen:GetEffectName()
	return "particles/icebreaker/icebreaker_blur.vpcf"
end

function icebreaker_u_modifier_degen:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end