_status_efx_example = class({})

function _status_efx_example:IsHidden()
	return true
end

function _status_efx_example:IsPurgable()
	return false
end

-----------------------------------------------------------

function _status_efx_example:OnCreated(kv)
end

function _status_efx_example:OnRefresh(kv)
end

function _status_efx_example:OnRemoved()
end

-----------------------------------------------------------

function _status_efx_example:GetStatusEffectName()
    return ""
end

function _status_efx_example:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end