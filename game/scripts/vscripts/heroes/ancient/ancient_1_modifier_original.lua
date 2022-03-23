ancient_1_modifier_original = class ({})

function ancient_1_modifier_original:IsHidden()
    return true
end

function ancient_1_modifier_original:IsPurgable()
    return false
end

-----------------------------------------------------------

function ancient_1_modifier_original:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function ancient_1_modifier_original:OnRefresh(kv)
end

function ancient_1_modifier_original:OnRemoved(kv)
end

------------------------------------------------------------

function ancient_1_modifier_original:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}

	return funcs
end

function ancient_1_modifier_original:GetModifierIncomingDamage_Percentage(keys)
	if keys.attacker ~= self.caster then return end
	self.ability.original_damage = keys.original_damage
end