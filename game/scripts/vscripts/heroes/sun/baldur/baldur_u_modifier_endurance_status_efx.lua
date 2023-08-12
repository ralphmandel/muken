baldur_u_modifier_endurance_status_efx = class({})

function baldur_u_modifier_endurance_status_efx:IsHidden() return true end
function baldur_u_modifier_endurance_status_efx:IsPurgable() return false end

-----------------------------------------------------------

function baldur_u_modifier_endurance_status_efx:OnCreated(kv)
end

function baldur_u_modifier_endurance_status_efx:OnRefresh(kv)
end

function baldur_u_modifier_endurance_status_efx:OnRemoved()
end

-----------------------------------------------------------

function baldur_u_modifier_endurance_status_efx:GetStatusEffectName()
  return "particles/bald/bald_vitality/bald_vitality_status_efx.vpcf"
end

function baldur_u_modifier_endurance_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end