crusader_1_modifier_charges = class ({})

function crusader_1_modifier_charges:IsHidden()
    return false
end

function crusader_1_modifier_charges:IsPurgable()
    return false
end

-----------------------------------------------------------

function crusader_1_modifier_charges:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function crusader_1_modifier_charges:OnRefresh(kv)
end

function crusader_1_modifier_charges:OnRemoved(kv)
	local passive = self.parent:FindModifierByName("crusader_1_modifier_passive")
	if passive then
		if self.parent:IsAlive() then
			passive:IncrementStackCount()
		else
			passive:CheckCharges()
		end
	end
end

------------------------------------------------------------

function crusader_1_modifier_charges:OnIntervalThink(keys)
end