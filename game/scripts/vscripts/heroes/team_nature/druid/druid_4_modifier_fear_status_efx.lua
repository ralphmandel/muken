druid_4_modifier_fear_status_efx = class ({})

function druid_4_modifier_fear_status_efx:IsHidden()
    return true
end

function druid_4_modifier_fear_status_efx:IsPurgable()
    return false
end

-----------------------------------------------------------

function druid_4_modifier_fear_status_efx:OnCreated(kv)
end

function druid_4_modifier_fear_status_efx:OnRefresh(kv)
end

function druid_4_modifier_fear_status_efx:OnRemoved(kv)
end

-----------------------------------------------------------

function druid_4_modifier_fear_status_efx:GetStatusEffectName()
	return "particles/status_fx/status_effect_lone_druid_savage_roar.vpcf"
end

function druid_4_modifier_fear_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end