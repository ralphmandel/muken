bloodstained_u_modifier_copy_status_efx = class({})

function bloodstained_u_modifier_copy_status_efx:IsHidden() return true end
function bloodstained_u_modifier_copy_status_efx:IsPurgable() return false end

-----------------------------------------------------------

function bloodstained_u_modifier_copy_status_efx:OnCreated(kv)
end

function bloodstained_u_modifier_copy_status_efx:OnRefresh(kv)
end

function bloodstained_u_modifier_copy_status_efx:OnRemoved()
end

-----------------------------------------------------------

function bloodstained_u_modifier_copy_status_efx:GetStatusEffectName()
    return "particles/bloodstained/bloodstained_u_illusion_status.vpcf"
end

function bloodstained_u_modifier_copy_status_efx:StatusEffectPriority()
	return 99999999
end