shadow_0_modifier_passive = class({})

function shadow_0_modifier_passive:IsHidden()
	return true
end

function shadow_0_modifier_passive:IsPurgable()
	return false
end

-----------------------------------------------------------

function shadow_0_modifier_passive:OnCreated(kv)
	self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function shadow_0_modifier_passive:OnRefresh(kv)
end

function shadow_0_modifier_passive:OnRemoved()
end

-----------------------------------------------------------

function shadow_0_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_FAIL
	}

	return funcs
end

-----------------------------------------------------------

function shadow_0_modifier_passive:OnAttackLanded(keys)
	if self.parent:PassivesDisabled() then return end
	if self.parent ~= keys.target then return end
	if keys.attacker:IsMagicImmune() then return end
	if keys.attacker:GetTeamNumber() == self.parent:GetTeamNumber() then return end

	-- UP 0.31
	if self.ability:GetRank(31)
	and RandomInt(1, 100) <= 15 then
		keys.attacker:AddNewModifier(self.caster, self.ability, "shadow_0_modifier_toxin", {})
	end
end

function shadow_0_modifier_passive:OnAttackFail(keys)
	if self.parent:PassivesDisabled() then return end
	if self.parent ~= keys.target then return end
	if keys.attacker:IsMagicImmune() then return end
	if keys.attacker:GetTeamNumber() == self.parent:GetTeamNumber() then return end

	-- UP 0.31
	if self.ability:GetRank(31)
	and RandomInt(1, 100) <= 15 then
		keys.attacker:AddNewModifier(self.caster, self.ability, "shadow_0_modifier_toxin", {})
	end
end