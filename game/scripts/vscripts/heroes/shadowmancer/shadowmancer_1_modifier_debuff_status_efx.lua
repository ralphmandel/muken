shadowmancer_1_modifier_debuff_status_efx = class({})

function shadowmancer_1_modifier_debuff_status_efx:IsHidden()
	return true
end

function shadowmancer_1_modifier_debuff_status_efx:IsPurgable()
	return false
end

-----------------------------------------------------------

function shadowmancer_1_modifier_debuff_status_efx:OnCreated(kv)
end

function shadowmancer_1_modifier_debuff_status_efx:OnRefresh(kv)
end

function shadowmancer_1_modifier_debuff_status_efx:OnRemoved()
end

-----------------------------------------------------------

function shadowmancer_1_modifier_debuff_status_efx:GetStatusEffectName()
    return "particles/status_fx/status_effect_maledict.vpcf"
end

function shadowmancer_1_modifier_debuff_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end