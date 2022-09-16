druid_4_modifier_aura_effect = class({})

function druid_4_modifier_aura_effect:IsHidden()
	return false
end

function druid_4_modifier_aura_effect:IsPurgable()
	return false
end

function druid_4_modifier_aura_effect:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_4_modifier_aura_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.aspd = self.ability:GetSpecialValueFor("aspd")
end

function druid_4_modifier_aura_effect:OnRefresh(kv)
end

function druid_4_modifier_aura_effect:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_4_modifier_aura_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE
	}

	return funcs
end

function druid_4_modifier_aura_effect:GetModifierAttackSpeedPercentage()
    return self.aspd
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function druid_4_modifier_aura_effect:GetEffectName()
	return "particles/units/heroes/hero_lycan/lycan_howl_buff.vpcf"
end

function druid_4_modifier_aura_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end
