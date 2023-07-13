fleaman_1_modifier_precision_status_efx = class({})

function fleaman_1_modifier_precision_status_efx:IsHidden() return true end
function fleaman_1_modifier_precision_status_efx:IsPurgable() return false end

-----------------------------------------------------------

function fleaman_1_modifier_precision_status_efx:OnCreated(kv)
end

function fleaman_1_modifier_precision_status_efx:OnRefresh(kv)
end

function fleaman_1_modifier_precision_status_efx:OnRemoved()
end

-----------------------------------------------------------

function fleaman_1_modifier_precision_status_efx:GetStatusEffectName()
    return "particles/status_fx/status_effect_slark_shadow_dance.vpcf"
end

function fleaman_1_modifier_precision_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end