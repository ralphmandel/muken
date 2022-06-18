icebreaker_0_modifier_slow_status_efx = class ({})

function icebreaker_0_modifier_slow_status_efx:IsHidden()
    return true
end

function icebreaker_0_modifier_slow_status_efx:IsPurgable()
    return false
end

-----------------------------------------------------------

function icebreaker_0_modifier_slow_status_efx:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function icebreaker_0_modifier_slow_status_efx:OnRefresh(kv)
end

------------------------------------------------------------

function icebreaker_0_modifier_slow_status_efx:GetStatusEffectName()
	return "particles/econ/items/drow/drow_ti9_immortal/status_effect_drow_ti9_frost_arrow.vpcf"
end

function icebreaker_0_modifier_slow_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end