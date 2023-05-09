ancient_2_modifier_damage = class({})

function ancient_2_modifier_damage:IsHidden()
	return true
end

function ancient_2_modifier_damage:IsPurgable()
	return false
end

function ancient_2_modifier_damage:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_2_modifier_damage:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function ancient_2_modifier_damage:OnRefresh(kv)
end

function ancient_2_modifier_damage:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_2_modifier_damage:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL
	}

	return funcs
end

function ancient_2_modifier_damage:GetModifierBaseDamageOutgoing_Percentage()
	return self.ability.damage_percent
end

function ancient_2_modifier_damage:GetModifierProcAttack_BonusDamage_Physical()
	return self.ability.damage
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------