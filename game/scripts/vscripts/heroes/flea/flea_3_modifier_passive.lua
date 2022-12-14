flea_3_modifier_passive = class({})

function flea_3_modifier_passive:IsHidden() return true end
function flea_3_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_3_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function flea_3_modifier_passive:OnRefresh(kv)
end

function flea_3_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_3_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function flea_3_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self.parent:PassivesDisabled() then return end

	local special_reset_chance = self.ability:GetSpecialValueFor("special_reset_chance")

	if RandomFloat(1, 100) <= special_reset_chance then
		self.ability:EndCooldown()
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------