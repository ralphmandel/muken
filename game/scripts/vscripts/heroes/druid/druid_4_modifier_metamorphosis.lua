druid_4_modifier_metamorphosis = class({})

function druid_4_modifier_metamorphosis:IsHidden()
	return false
end

function druid_4_modifier_metamorphosis:IsPurgable()
	return false
end

function druid_4_modifier_metamorphosis:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_4_modifier_metamorphosis:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.heal_power = self.ability:GetSpecialValueFor("heal_power")
	local con = self.ability:GetSpecialValueFor("con")

	self.ability:AddBonus("_1_CON", self.parent, con, 0, nil)
	self.ability:SetActivated(false)
	self.ability:EndCooldown()
end

function druid_4_modifier_metamorphosis:OnRefresh(kv)
end

function druid_4_modifier_metamorphosis:OnRemoved()
	self.ability:RemoveBonus("_1_CON", self.parent)
	self.ability:SetActivated(true)
	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_4_modifier_metamorphosis:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE
	}

	return funcs
end

function druid_4_modifier_metamorphosis:GetModifierHealAmplify_PercentageTarget()
    return self.heal_power
end

function druid_4_modifier_metamorphosis:GetModifierHPRegenAmplify_Percentage(keys)
    return self.heal_power
end


-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------