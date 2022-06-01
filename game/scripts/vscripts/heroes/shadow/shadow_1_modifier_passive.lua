shadow_1_modifier_passive = class({})

function shadow_1_modifier_passive:IsHidden()
	return true
end

function shadow_1_modifier_passive:IsPurgable()
	return false
end

-----------------------------------------------------------

function shadow_1_modifier_passive:OnCreated(kv)
	self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function shadow_1_modifier_passive:OnRefresh(kv)
end

function shadow_1_modifier_passive:OnRemoved()
end

-----------------------------------------------------------

function shadow_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function shadow_1_modifier_passive:OnAttackLanded(keys)
	local toxin_ability = self.caster:FindAbilityByName("shadow_0__toxin")
	if toxin_ability == nil then return end
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if keys.target:IsMagicImmune() then return end
	if self.parent:PassivesDisabled() then return end
	local chance = self.ability:GetSpecialValueFor("chance")
	
	if RandomInt(1, 100) <= chance then
		keys.target:AddNewModifier(self.caster, toxin_ability, "shadow_0_modifier_toxin", {})
	end
end