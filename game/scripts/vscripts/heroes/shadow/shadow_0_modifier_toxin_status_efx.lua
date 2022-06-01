shadow_0_modifier_toxin_status_efx = class({})

function shadow_0_modifier_toxin_status_efx:IsHidden()
	return true
end

function shadow_0_modifier_toxin_status_efx:IsPurgable()
	return false
end

-----------------------------------------------------------

function shadow_0_modifier_toxin_status_efx:OnCreated(kv)
end

function shadow_0_modifier_toxin_status_efx:OnRefresh(kv)
end

function shadow_0_modifier_toxin_status_efx:OnRemoved()
end

-----------------------------------------------------------

function shadow_0_modifier_toxin_status_efx:GetStatusEffectName()
    return "particles/status_fx/status_effect_maledict.vpcf"
end

function shadow_0_modifier_toxin_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end