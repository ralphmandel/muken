osiris_1_modifier_poison_status_efx = class({})

function osiris_1_modifier_poison_status_efx:IsHidden()
	return true
end

function osiris_1_modifier_poison_status_efx:IsPurgable()
	return false
end

-----------------------------------------------------------

function osiris_1_modifier_poison_status_efx:OnCreated(kv)
end

function osiris_1_modifier_poison_status_efx:OnRefresh(kv)
end

function osiris_1_modifier_poison_status_efx:OnRemoved()
end

-----------------------------------------------------------

function osiris_1_modifier_poison_status_efx:GetStatusEffectName()
    return "particles/osiris/poison_debuff_alt/osiris_poison_status_efx.vpcf"
end

function osiris_1_modifier_poison_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end