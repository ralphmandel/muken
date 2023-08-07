icebreaker__modifier_hypo_status_efx = class({})

function icebreaker__modifier_hypo_status_efx:IsHidden() return true end
function icebreaker__modifier_hypo_status_efx:IsPurgable() return false end

-----------------------------------------------------------

function icebreaker__modifier_hypo_status_efx:OnCreated(kv)
end

function icebreaker__modifier_hypo_status_efx:OnRefresh(kv)
end

function icebreaker__modifier_hypo_status_efx:OnRemoved()
end

-----------------------------------------------------------

function icebreaker__modifier_hypo_status_efx:GetStatusEffectName()
    return "particles/econ/items/drow/drow_ti9_immortal/status_effect_drow_ti9_frost_arrow.vpcf"
end

function icebreaker__modifier_hypo_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end