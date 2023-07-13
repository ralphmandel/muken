bloodstained_1_modifier_rage_status_efx = class({})

function bloodstained_1_modifier_rage_status_efx:IsHidden() return true end
function bloodstained_1_modifier_rage_status_efx:IsPurgable() return false end

-----------------------------------------------------------

function bloodstained_1_modifier_rage_status_efx:OnCreated(kv)
end

function bloodstained_1_modifier_rage_status_efx:OnRefresh(kv)
end

function bloodstained_1_modifier_rage_status_efx:OnRemoved()
end

-----------------------------------------------------------

function bloodstained_1_modifier_rage_status_efx:GetStatusEffectName()
  return "particles/econ/items/lifestealer/lifestealer_immortal_backbone/status_effect_life_stealer_immortal_rage.vpcf"
end

function bloodstained_1_modifier_rage_status_efx:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end