bloodstained__modifier_bleeding_status_efx = class({})

function bloodstained__modifier_bleeding_status_efx:IsHidden()
	return true
end

function bloodstained__modifier_bleeding_status_efx:IsPurgable()
	return false
end

function bloodstained__modifier_bleeding_status_efx:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-----------------------------------------------------------

function bloodstained__modifier_bleeding_status_efx:OnCreated(kv)
end

function bloodstained__modifier_bleeding_status_efx:OnRefresh(kv)
end

function bloodstained__modifier_bleeding_status_efx:OnRemoved()
end

-----------------------------------------------------------

function bloodstained__modifier_bleeding_status_efx:GetStatusEffectName()
    return "particles/status_fx/status_effect_rupture.vpcf"
end

function bloodstained__modifier_bleeding_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end