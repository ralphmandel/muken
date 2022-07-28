krieger_1_modifier_passive_status_efx = class ({})

function krieger_1_modifier_passive_status_efx:IsHidden()
    return true
end

function krieger_1_modifier_passive_status_efx:IsPurgable()
    return false
end

-----------------------------------------------------------

function krieger_1_modifier_passive_status_efx:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function krieger_1_modifier_passive_status_efx:OnRefresh(kv)
end

------------------------------------------------------------

function krieger_1_modifier_passive_status_efx:GetStatusEffectName()
	return "particles/krieger/status_effect_krieger.vpcf"
end

function krieger_1_modifier_passive_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end