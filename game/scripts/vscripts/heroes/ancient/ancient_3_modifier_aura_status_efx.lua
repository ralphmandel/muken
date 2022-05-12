ancient_3_modifier_aura_status_efx = class({})

function ancient_3_modifier_aura_status_efx:IsHidden()
	return true
end

function ancient_3_modifier_aura_status_efx:IsPurgable()
	return false
end

-----------------------------------------------------------

function ancient_3_modifier_aura_status_efx:OnCreated(kv)
end

function ancient_3_modifier_aura_status_efx:OnRefresh(kv)
end

function ancient_3_modifier_aura_status_efx:OnRemoved()
end

-----------------------------------------------------------

function ancient_3_modifier_aura_status_efx:GetStatusEffectName()
	return "particles/status_fx/status_effect_statue.vpcf"
end

function ancient_3_modifier_aura_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end