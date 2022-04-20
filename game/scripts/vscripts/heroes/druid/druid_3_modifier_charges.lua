druid_3_modifier_charges = class ({})

function druid_3_modifier_charges:IsHidden()
	if self:GetAbility():GetCurrentAbilityCharges() == 0 then return true end
	if self:GetAbility():GetCurrentAbilityCharges() == 1 then return true end
	if self:GetAbility():GetCurrentAbilityCharges() % 3 == 0 then return false end
	return true
end

function druid_3_modifier_charges:IsPurgable()
    return false
end

-----------------------------------------------------------

function druid_3_modifier_charges:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function druid_3_modifier_charges:OnRefresh(kv)
end

function druid_3_modifier_charges:OnRemoved(kv)
	local passive = self.parent:FindModifierByName("druid_3_modifier_passive")
	if passive then
		if self.parent:IsAlive() then
			passive:IncrementStackCount()
		else
			passive:CheckCharges()
		end
	end
end

------------------------------------------------------------

function druid_3_modifier_charges:OnIntervalThink(keys)
end