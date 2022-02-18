shadow_u_modifier_dagger = class({})

function shadow_u_modifier_dagger:IsPurgable()
	return false
end

function shadow_u_modifier_dagger:IsHidden()
	return true
end

-------------------------------------------------------------------

function shadow_u_modifier_dagger:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
end

function shadow_u_modifier_dagger:OnRefresh(kv)
end

function shadow_u_modifier_dagger:OnRemoved()
end

-------------------------------------------------------------------
