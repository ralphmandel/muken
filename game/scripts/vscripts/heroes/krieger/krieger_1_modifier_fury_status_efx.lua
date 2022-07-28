krieger_1_modifier_fury_status_efx = class ({})

function krieger_1_modifier_fury_status_efx:IsHidden()
    return true
end

function krieger_1_modifier_fury_status_efx:IsPurgable()
    return false
end

-----------------------------------------------------------

function krieger_1_modifier_fury_status_efx:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function krieger_1_modifier_fury_status_efx:OnRefresh(kv)
end

------------------------------------------------------------

function krieger_1_modifier_fury_status_efx:GetStatusEffectName()
	return "particles/econ/items/lifestealer/lifestealer_immortal_backbone/status_effect_life_stealer_immortal_rage.vpcf"
end

function krieger_1_modifier_fury_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end