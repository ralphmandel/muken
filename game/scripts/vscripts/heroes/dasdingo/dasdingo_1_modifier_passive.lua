dasdingo_1_modifier_passive = class({})

function dasdingo_1_modifier_passive:IsHidden()
	return true
end

function dasdingo_1_modifier_passive:IsPurgable()
	return false
end

-----------------------------------------------------------

function dasdingo_1_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.heal_amp = self.ability:GetSpecialValueFor("heal_amp")
end

function dasdingo_1_modifier_passive:OnRefresh(kv)
	self.heal_amp = self.ability:GetSpecialValueFor("heal_amp")
end

function dasdingo_1_modifier_passive:OnRemoved(kv)
end

-----------------------------------------------------------

function dasdingo_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
	}

	return funcs
end

function dasdingo_1_modifier_passive:GetModifierHealAmplify_PercentageTarget()
	return self.heal_amp
end