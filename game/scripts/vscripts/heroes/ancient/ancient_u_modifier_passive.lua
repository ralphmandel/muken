ancient_u_modifier_passive = class ({})

function ancient_u_modifier_passive:IsHidden()
    return false
end

function ancient_u_modifier_passive:IsPurgable()
    return false
end

-----------------------------------------------------------

function ancient_u_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function ancient_u_modifier_passive:OnRefresh(kv)
end

function ancient_u_modifier_passive:OnRemoved(kv)
end

------------------------------------------------------------

function ancient_u_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_SPELL_DAMAGE_CONSTANT
	}

	return funcs
end

function ancient_u_modifier_passive:GetModifierIncomingSpellDamageConstant(keys)
	local damage = 0
	local percent = self.ability:GetSpecialValueFor("percent")
	if keys.damage_type == DAMAGE_TYPE_PURE then damage = keys.original_damage end
	if keys.damage_type == DAMAGE_TYPE_MAGICAL then damage = keys.damage end

	local reduction = damage * percent * self.parent:GetMana() * 0.01
	return -reduction
end