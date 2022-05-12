bocuse_u_modifier_mise_status_efx = class({})

function bocuse_u_modifier_mise_status_efx:IsHidden()
	return true
end

function bocuse_u_modifier_mise_status_efx:IsPurgable()
	return false
end

-----------------------------------------------------------

function bocuse_u_modifier_mise_status_efx:OnCreated(kv)
end

function bocuse_u_modifier_mise_status_efx:OnRefresh(kv)
end

function bocuse_u_modifier_mise_status_efx:OnRemoved()
end

-----------------------------------------------------------

function bocuse_u_modifier_mise_status_efx:GetStatusEffectName()
	return "particles/econ/items/invoker/invoker_ti7/status_effect_alacrity_ti7.vpcf"
end

function bocuse_u_modifier_mise_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end