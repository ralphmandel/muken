druid_1_modifier_failed = class ({})

function druid_1_modifier_failed:IsHidden()
    return false
end

function druid_1_modifier_failed:IsPurgable()
    return false
end

-----------------------------------------------------------

function druid_1_modifier_failed:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function druid_1_modifier_failed:OnRefresh(kv)
end

function druid_1_modifier_failed:OnRemoved(kv)
end

------------------------------------------------------------