bald_1_modifier_passive = class({})

function bald_1_modifier_passive:IsHidden()
	return true
end

function bald_1_modifier_passive:IsPurgable()
	return false
end

function bald_1_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_1_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function bald_1_modifier_passive:OnRefresh(kv)
end

function bald_1_modifier_passive:OnRemoved()
	self.ability:RemoveBonus("_1_STR", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function bald_1_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if self.parent:PassivesDisabled() then return end

	if self.ability:IsCooldownReady() then
		self.ability:AddBonus("_1_STR", self.parent, 1, 0, 60)
		self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------