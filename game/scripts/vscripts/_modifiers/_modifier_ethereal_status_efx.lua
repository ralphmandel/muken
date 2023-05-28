_modifier_ethereal_status_efx = class({})

function _modifier_ethereal_status_efx:IsHidden()
	return true
end

function _modifier_ethereal_status_efx:IsPurgable()
	return false
end

-----------------------------------------------------------

function _modifier_ethereal_status_efx:OnCreated(kv)
end

function _modifier_ethereal_status_efx:OnRefresh(kv)
end

function _modifier_ethereal_status_efx:OnRemoved()
end

-----------------------------------------------------------

function _modifier_ethereal_status_efx:GetStatusEffectName()
	return "particles/status_fx/status_effect_ghost.vpcf"
end

function _modifier_ethereal_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end