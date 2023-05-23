ancient_2_modifier_passive = class({})

function ancient_2_modifier_passive:IsHidden()
	return true
end

function ancient_2_modifier_passive:IsPurgable()
	return false
end

function ancient_2_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_2_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function ancient_2_modifier_passive:OnRefresh(kv)
end

function ancient_2_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_2_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function ancient_2_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if self.ability:IsCooldownReady() then return end
	if self.parent:PassivesDisabled() then return end

	-- UP 2.31
	if self.ability:GetRank(31) then
		local cd = self.ability:GetCooldownTimeRemaining() - 1.5
		self.ability:EndCooldown()
		self.ability:StartCooldown(cd)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------