icebreaker_u_modifier_status_effect = class ({})

function icebreaker_u_modifier_status_effect:IsHidden()
    return true
end

function icebreaker_u_modifier_status_effect:IsPurgable()
    return false
end

-----------------------------------------------------------

function icebreaker_u_modifier_status_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function icebreaker_u_modifier_status_effect:OnRefresh(kv)
end

------------------------------------------------------------

function icebreaker_u_modifier_status_effect:GetStatusEffectName()
	return "particles/econ/items/effigies/status_fx_effigies/status_effect_effigy_frosty_l2_radiant.vpcf"
end

function icebreaker_u_modifier_status_effect:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end