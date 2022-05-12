_modifier_status_effect = class({})

function _modifier_status_effect:IsHidden()
	return true
end

function _modifier_status_effect:IsPurgable()
	return false
end

function _modifier_status_effect:IsDebuff()
	return false
end

-----------------------------------------------------------

function _modifier_status_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.efx_name = kv.name
	self.efx_level = kv.level
end

function _modifier_status_effect:OnRefresh(kv)
end

function _modifier_status_effect:OnRemoved()
end

-----------------------------------------------------------

function _modifier_status_effect:GetStatusEffectName()
	return "particles/status_fx/status_effect_statue.vpcf"
end

function _modifier_status_effect:StatusEffectPriority()
	return self.efx_level
end