item_potion_recover_modifier = class({})

function item_potion_recover_modifier:IsHidden()
    return false
end

function item_potion_recover_modifier:IsPurgable()
    return false
end

---------------------------------------------------------------------------------------------------

function item_potion_recover_modifier:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.mana = self.ability:GetSpecialValueFor("mana")
	if IsServer() then self:StartIntervalThink(1) end
end

function item_potion_recover_modifier:OnRefresh( kv )
end

function item_potion_recover_modifier:OnRemoved( kv )
	self.ability:SetDroppable(true)
	self.ability:SetActivated(true)
	self.ability:SpendCharge()
end

---------------------------------------------------------------------------------------------------

function item_potion_recover_modifier:OnIntervalThink()
	local mana = self.mana
	if self.parent:GetUnitName() == "npc_dota_hero_elder_titan" then mana = mana * 0.5 end
	self.parent:GiveMana(mana)
	SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_ADD, self.parent, mana, self.caster)
end

--------------------------------------------------------------------------------------------------

function item_potion_recover_modifier:GetEffectName()
	return "particles/generic/flask_recover.vpcf"
end

function item_potion_recover_modifier:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end