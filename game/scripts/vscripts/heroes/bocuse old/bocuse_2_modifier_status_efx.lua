bocuse_2_modifier_status_efx = class({})

function bocuse_2_modifier_status_efx:IsHidden()
	return true
end

function bocuse_2_modifier_status_efx:IsPurgable()
	return false
end

-----------------------------------------------------------

function bocuse_2_modifier_status_efx:OnCreated(kv)
end

function bocuse_2_modifier_status_efx:OnRefresh(kv)
end

function bocuse_2_modifier_status_efx:OnRemoved()
end

-----------------------------------------------------------

function bocuse_2_modifier_status_efx:GetStatusEffectName()
    return "particles/econ/items/lifestealer/ls_ti9_immortal/status_effect_ls_ti9_open_wounds.vpcf"
end

function bocuse_2_modifier_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end