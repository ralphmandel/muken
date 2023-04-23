bald_u_modifier_vitality_status_efx = class({})

function bald_u_modifier_vitality_status_efx:IsHidden() return true end
function bald_u_modifier_vitality_status_efx:IsPurgable() return false end

-----------------------------------------------------------

function bald_u_modifier_vitality_status_efx:OnCreated(kv)
end

function bald_u_modifier_vitality_status_efx:OnRefresh(kv)
end

function bald_u_modifier_vitality_status_efx:OnRemoved()
end

-----------------------------------------------------------

function bald_u_modifier_vitality_status_efx:GetStatusEffectName()
    return "particles/bald/bald_vitality/bald_vitality_status_efx.vpcf"
end

function bald_u_modifier_vitality_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end