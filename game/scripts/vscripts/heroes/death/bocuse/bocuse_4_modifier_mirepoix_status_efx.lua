bocuse_4_modifier_mirepoix_status_efx = class({})

function bocuse_4_modifier_mirepoix_status_efx:IsHidden() return true end
function bocuse_4_modifier_mirepoix_status_efx:IsPurgable() return false end

-----------------------------------------------------------

function bocuse_4_modifier_mirepoix_status_efx:OnCreated(kv)
end

function bocuse_4_modifier_mirepoix_status_efx:OnRefresh(kv)
end

function bocuse_4_modifier_mirepoix_status_efx:OnRemoved()
end

-----------------------------------------------------------

function bocuse_4_modifier_mirepoix_status_efx:GetStatusEffectName()
  return "particles/status_fx/status_effect_shield_rune.vpcf"
end

function bocuse_4_modifier_mirepoix_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end