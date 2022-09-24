_modifier_petrified_status_efx = class({})

function _modifier_petrified_status_efx:IsHidden()
	return true
end

function _modifier_petrified_status_efx:IsPurgable()
	return false
end

-----------------------------------------------------------

function _modifier_petrified_status_efx:OnCreated(kv)
end

function _modifier_petrified_status_efx:OnRefresh(kv)
end

function _modifier_petrified_status_efx:OnRemoved()
end

-----------------------------------------------------------

function _modifier_petrified_status_efx:GetStatusEffectName()
    return "particles/status_fx/status_effect_medusa_stone_gaze.vpcf"
end

function _modifier_petrified_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end