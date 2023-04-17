item_potion_speed_modifier = class({})

function item_potion_speed_modifier:IsHidden()
    return false
end

function item_potion_speed_modifier:IsPurgable()
    return false
end

---------------------------------------------------------------------------------------------------

function item_potion_speed_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local ms = self.ability:GetSpecialValueFor("ms")
	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {percent = ms})

	if IsServer() then self:StartIntervalThink(1) end
end

function item_potion_speed_modifier:OnRefresh( kv )
end

function item_potion_speed_modifier:OnRemoved( kv )
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_buff", self.ability)
	
	self.ability:SetDroppable(true)
	self.ability:SetActivated(true)
	self.ability:SpendCharge()
end

--------------------------------------------------------------------------------------------------

function item_potion_speed_modifier:GetEffectName()
	return "particles/generic/flask_speed.vpcf"
end

function item_potion_speed_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end