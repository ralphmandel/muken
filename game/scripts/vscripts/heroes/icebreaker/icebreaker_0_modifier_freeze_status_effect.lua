icebreaker_0_modifier_freeze_status_effect = class ({})

function icebreaker_0_modifier_freeze_status_effect:IsHidden()
    return true
end

function icebreaker_0_modifier_freeze_status_effect:IsPurgable()
    return false
end

-----------------------------------------------------------

function icebreaker_0_modifier_freeze_status_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function icebreaker_0_modifier_freeze_status_effect:OnRefresh(kv)
end

------------------------------------------------------------

function icebreaker_0_modifier_freeze_status_effect:GetStatusEffectName()
	return "particles/econ/items/drow/drow_ti9_immortal/status_effect_drow_ti9_frost_arrow.vpcf"
end

function icebreaker_0_modifier_freeze_status_effect:StatusEffectPriority()
	return MODIFIER_PRIORITY_ULTRA
end