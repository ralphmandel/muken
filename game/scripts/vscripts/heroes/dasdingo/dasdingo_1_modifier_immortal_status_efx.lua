dasdingo_1_modifier_immortal_status_efx = class({})

function dasdingo_1_modifier_immortal_status_efx:IsHidden()
	return true
end

function dasdingo_1_modifier_immortal_status_efx:IsPurgable()
	return false
end

-----------------------------------------------------------

function dasdingo_1_modifier_immortal_status_efx:OnCreated(kv)
end

function dasdingo_1_modifier_immortal_status_efx:OnRefresh(kv)
end

function dasdingo_1_modifier_immortal_status_efx:OnRemoved()
end

-----------------------------------------------------------

function dasdingo_1_modifier_immortal_status_efx:GetStatusEffectName()
	return "particles/status_fx/status_effect_wraithking_ghosts.vpcf"
end

function dasdingo_1_modifier_immortal_status_efx:StatusEffectPriority()
	return 99999999
end