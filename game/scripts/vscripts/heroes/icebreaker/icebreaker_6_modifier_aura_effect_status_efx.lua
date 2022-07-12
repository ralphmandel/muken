icebreaker_6_modifier_aura_effect_status_efx = class({})

function icebreaker_6_modifier_aura_effect_status_efx:IsHidden()
	return true
end

function icebreaker_6_modifier_aura_effect_status_efx:IsPurgable()
	return false
end

-----------------------------------------------------------

function icebreaker_6_modifier_aura_effect_status_efx:OnCreated(kv)
end

function icebreaker_6_modifier_aura_effect_status_efx:OnRefresh(kv)
end

function icebreaker_6_modifier_aura_effect_status_efx:OnRemoved()
end

------------------------------------------------------------

function icebreaker_6_modifier_aura_effect_status_efx:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_l2_radiant.vpcf"
end

function icebreaker_6_modifier_aura_effect_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end