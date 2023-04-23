bald_5_modifier_call_status_efx = class({})

function bald_5_modifier_call_status_efx:IsHidden() return true end
function bald_5_modifier_call_status_efx:IsPurgable() return false end

-----------------------------------------------------------

function bald_5_modifier_call_status_efx:OnCreated(kv)
end

function bald_5_modifier_call_status_efx:OnRefresh(kv)
end

function bald_5_modifier_call_status_efx:OnRemoved()
end

-----------------------------------------------------------

function bald_5_modifier_call_status_efx:GetStatusEffectName()
    return "particles/status_fx/status_effect_beserkers_call.vpcf"
end

function bald_5_modifier_call_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end