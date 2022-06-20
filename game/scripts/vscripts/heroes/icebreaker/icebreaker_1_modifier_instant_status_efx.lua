icebreaker_1_modifier_instant_status_efx = class ({})

function icebreaker_1_modifier_instant_status_efx:IsHidden()
    return true
end

function icebreaker_1_modifier_instant_status_efx:IsPurgable()
    return false
end

-----------------------------------------------------------

function icebreaker_1_modifier_instant_status_efx:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function icebreaker_1_modifier_instant_status_efx:OnRefresh(kv)
end

------------------------------------------------------------

function icebreaker_1_modifier_instant_status_efx:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_l2_radiant.vpcf"
end

function icebreaker_1_modifier_instant_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end