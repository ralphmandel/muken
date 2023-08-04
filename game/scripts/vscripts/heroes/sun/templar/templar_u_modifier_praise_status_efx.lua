templar_u_modifier_praise_status_efx = class({})

function templar_u_modifier_praise_status_efx:IsHidden() return true end
function templar_u_modifier_praise_status_efx:IsPurgable() return false end

-----------------------------------------------------------

function templar_u_modifier_praise_status_efx:OnCreated(kv)
end

function templar_u_modifier_praise_status_efx:OnRefresh(kv)
end

function templar_u_modifier_praise_status_efx:OnRemoved()
end

-----------------------------------------------------------

function templar_u_modifier_praise_status_efx:GetStatusEffectName()
  return "particles/status_fx/status_effect_shield_rune.vpcf"
end

function templar_u_modifier_praise_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end