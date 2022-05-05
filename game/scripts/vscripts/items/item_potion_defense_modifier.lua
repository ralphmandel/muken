item_potion_defense_modifier = class({})

function item_potion_defense_modifier:IsHidden()
    return false
end

function item_potion_defense_modifier:IsPurgable()
    return false
end

---------------------------------------------------------------------------------------------------

function item_potion_defense_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.armor = self.ability:GetSpecialValueFor("armor")
	if IsServer() then self:StartIntervalThink(1) end
end

function item_potion_defense_modifier:OnRefresh( kv )
end

function item_potion_defense_modifier:OnRemoved( kv )
	self.ability:SetDroppable(true)
	self.ability:SetActivated(true)
	self.ability:SpendCharge()
end

--------------------------------------------------------------------------------------------------

function item_potion_defense_modifier:DeclareFunctions()
    local funcs = {
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS
	}
	return funcs
end

function item_potion_defense_modifier:GetModifierPhysicalArmorBonus()
	return self.armor
end

--------------------------------------------------------------------------------------------------

function item_potion_defense_modifier:GetEffectName()
	return "particles/generic/flask_defense.vpcf"
end

function item_potion_defense_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end