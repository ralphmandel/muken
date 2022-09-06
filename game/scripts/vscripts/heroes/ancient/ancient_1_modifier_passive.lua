ancient_1_modifier_passive = class({})

function ancient_1_modifier_passive:IsHidden()
	return true
end

function ancient_1_modifier_passive:IsPurgable()
	return false
end

function ancient_1_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_1_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.damage = self.ability:GetSpecialValueFor("damage")
	self.stun_multiplier = self.ability:GetSpecialValueFor("stun_multiplier")

	local base_stats = self.parent:FindAbilityByName("base_stats")
	if base_stats then base_stats:SetBaseAttackTime(0) end
end

function ancient_1_modifier_passive:OnRefresh(kv)
end

function ancient_1_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function ancient_1_modifier_passive:GetModifierBaseDamageOutgoing_Percentage()
	return self.damage
end

function ancient_1_modifier_passive:OnTakeDamage(keys)
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end
	if self.parent:PassivesDisabled() then return end

	local stun_suration = keys.damage * self.stun_multiplier * 0.01

	keys.unit:AddNewModifier(self.caster, self.ability, "_modifier_stun", {
		duration = self.ability:CalcStatus(stun_suration, self.caster, keys.unit)
	})
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------