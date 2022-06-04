shadow_3_modifier_recharge = class({})

function shadow_3_modifier_recharge:IsHidden()
	return true
end

function shadow_3_modifier_recharge:IsPurgable()
	return false
end

-----------------------------------------------------------

function shadow_3_modifier_recharge:OnCreated(kv)
	self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function shadow_3_modifier_recharge:OnRefresh(kv)
end

function shadow_3_modifier_recharge:OnRemoved()
	self.ability:EndCooldown()
	ProjectileManager:ProjectileDodge(self.parent)
	self.parent:AddNewModifier(self.caster, self.ability, "shadow_3_modifier_walk", {})
end

-----------------------------------------------------------