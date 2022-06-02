shadow_3_modifier_passive = class({})

function shadow_3_modifier_passive:IsHidden()
	return true
end

function shadow_3_modifier_passive:IsPurgable()
	return false
end

-----------------------------------------------------------

function shadow_3_modifier_passive:OnCreated(kv)
	self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function shadow_3_modifier_passive:OnRefresh(kv)
end

function shadow_3_modifier_passive:OnRemoved()
end

-----------------------------------------------------------

function shadow_3_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

-----------------------------------------------------------

function shadow_3_modifier_passive:OnAttackLanded(keys)
	if self.parent ~= keys.attacker and self.parent ~= keys.target then return end
	local delay = self.ability:GetSpecialValueFor("delay")
	
	if self.ability:IsActivated() then self.ability:StartCooldown(delay) end
end