genuine_1_modifier_starfall_stack = class ({})

function genuine_1_modifier_starfall_stack:IsHidden()
    return true
end

function genuine_1_modifier_starfall_stack:IsPurgable()
    return false
end

function genuine_1_modifier_starfall_stack:IsDebuff()
    return true
end

function genuine_1_modifier_starfall_stack:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-----------------------------------------------------------

function genuine_1_modifier_starfall_stack:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function genuine_1_modifier_starfall_stack:OnRefresh(kv)
end

function genuine_1_modifier_starfall_stack:OnRemoved(kv)
end