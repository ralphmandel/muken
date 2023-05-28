doom_modifier_status_efx = class({})

function doom_modifier_status_efx:IsHidden()
	return true
end

function doom_modifier_status_efx:IsPurgable()
	return false
end

-----------------------------------------------------------

function doom_modifier_status_efx:OnCreated(kv)
end

function doom_modifier_status_efx:OnRefresh(kv)
end

function doom_modifier_status_efx:OnRemoved()
end

-----------------------------------------------------------

function doom_modifier_status_efx:GetStatusEffectName()
    return "particles/status_fx/status_effect_doom.vpcf"
end

function doom_modifier_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end