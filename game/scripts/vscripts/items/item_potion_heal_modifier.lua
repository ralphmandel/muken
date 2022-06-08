item_potion_heal_modifier = class({})

function item_potion_heal_modifier:IsHidden()
    return false
end

function item_potion_heal_modifier:IsPurgable()
    return false
end

---------------------------------------------------------------------------------------------------

function item_potion_heal_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.heal = self.ability:GetSpecialValueFor("heal")
	if IsServer() then self:StartIntervalThink(1) end
end

function item_potion_heal_modifier:OnRefresh( kv )
end

function item_potion_heal_modifier:OnRemoved( kv )
	self.ability:SetDroppable(true)
	self.ability:SetActivated(true)
	self.ability:SpendCharge()
end

---------------------------------------------------------------------------------------------------

function item_potion_heal_modifier:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function item_potion_heal_modifier:OnTakeDamage(keys)
	if keys.unit == self.parent then self:Destroy() end
end

function item_potion_heal_modifier:OnIntervalThink()
	self.parent:Heal(self.heal, self.ability)
end

--------------------------------------------------------------------------------------------------

function item_potion_heal_modifier:GetEffectName()
	return "particles/generic/flask_heal.vpcf"
end

function item_potion_heal_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end