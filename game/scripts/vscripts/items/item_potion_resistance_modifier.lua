item_potion_resistance_modifier = class({})

function item_potion_resistance_modifier:IsHidden()
    return false
end

function item_potion_resistance_modifier:IsPurgable()
    return false
end

---------------------------------------------------------------------------------------------------

function item_potion_resistance_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.resist = self.ability:GetSpecialValueFor("resist")
	if IsServer() then self:StartIntervalThink(1) end
end

function item_potion_resistance_modifier:OnRefresh( kv )
end

function item_potion_resistance_modifier:OnRemoved( kv )
	self.ability:SetDroppable(true)
	self.ability:SetActivated(true)
	self.ability:SpendCharge()
end

--------------------------------------------------------------------------------------------------

function item_potion_resistance_modifier:DeclareFunctions()
    local funcs = {
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS,
	}
	return funcs
end

function item_potion_resistance_modifier:GetModifierMagicalResistanceBonus()
    return self.resist
end

--------------------------------------------------------------------------------------------------

function item_potion_resistance_modifier:GetEffectName()
	return "particles/generic/flask_resistance.vpcf"
end

function item_potion_resistance_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end