item_potion_strenght_modifier = class({})

function item_potion_strenght_modifier:IsHidden()
    return false
end

function item_potion_strenght_modifier:IsPurgable()
    return false
end

---------------------------------------------------------------------------------------------------

function item_potion_strenght_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.bonus_damage = self.ability:GetSpecialValueFor("bonus_damage")
	if IsServer() then self:StartIntervalThink(1) end
end

function item_potion_strenght_modifier:OnRefresh( kv )
end

function item_potion_strenght_modifier:OnRemoved( kv )
	self.ability:SetDroppable(true)
	self.ability:SetActivated(true)
	self.ability:SpendCharge()
end

--------------------------------------------------------------------------------------------------

function item_potion_strenght_modifier:DeclareFunctions()
    local funcs = {
		MODIFIER_PROPERTY_PROCATTACK_BONUS_DAMAGE_PHYSICAL,
	}
	return funcs
end

function item_potion_strenght_modifier:GetModifierProcAttack_BonusDamage_Physical()
    return self.bonus_damage
end

--------------------------------------------------------------------------------------------------

function item_potion_strenght_modifier:GetEffectName()
	return "particles/generic/flask_strenght.vpcf"
end

function item_potion_strenght_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end