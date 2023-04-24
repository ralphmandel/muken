flea_5_modifier_passive = class({})

function flea_5_modifier_passive:IsHidden() return true end
function flea_5_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_5_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function flea_5_modifier_passive:OnRefresh(kv)
end

function flea_5_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_5_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PRE_ATTACK,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE_POST_CRIT,
	}

	return funcs
end

function flea_5_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if self.parent:PassivesDisabled() then return end
	if keys.target:HasModifier("flea_5_modifier_desolator") then return end

	local chance = self.ability:GetSpecialValueFor("chance")
	local duration = self.ability:GetSpecialValueFor("duration")

	if RandomFloat(0, 100) < chance then
		keys.target:AddNewModifier(self.caster, self.ability, "flea_5_modifier_desolator", {
			duration = CalcStatus(duration, self.caster, keys.target)
		})
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------