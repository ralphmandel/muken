genuine_0_modifier_fear_status_effect = class ({})

function genuine_0_modifier_fear_status_effect:IsHidden()
    return true
end

function genuine_0_modifier_fear_status_effect:IsPurgable()
    return false
end

-----------------------------------------------------------

function genuine_0_modifier_fear_status_effect:OnCreated(kv)
end

function genuine_0_modifier_fear_status_effect:OnRefresh(kv)
end

function genuine_0_modifier_fear_status_effect:OnRemoved(kv)
end

-----------------------------------------------------------

function genuine_0_modifier_fear_status_effect:GetStatusEffectName()
	return "particles/status_fx/status_effect_lone_druid_savage_roar.vpcf"
end

function genuine_0_modifier_fear_status_effect:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end