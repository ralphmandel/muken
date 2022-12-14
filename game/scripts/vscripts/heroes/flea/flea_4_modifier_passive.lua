flea_4_modifier_passive = class({})

function flea_4_modifier_passive:IsHidden() return true end
function flea_4_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_4_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function flea_4_modifier_passive:OnRefresh(kv)
end

function flea_4_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_4_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function flea_4_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self.parent:HasModifier("flea_4_modifier_smoke_effect") then return end
	if self.parent:PassivesDisabled() then return end

	if RandomFloat(1, 100) <= self.ability:GetSpecialValueFor("special_invi_chance") then
		self.parent:AddNewModifier(self.caster, self.ability, "flea_4_modifier_invi", {
			duration = self.ability:GetSpecialValueFor("special_invi_delay")
		})
		self.parent:MoveToTargetToAttack(keys.target)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------