fleaman_4_modifier_passive = class({})

function fleaman_4_modifier_passive:IsHidden() return true end
function fleaman_4_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function fleaman_4_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function fleaman_4_modifier_passive:OnRefresh(kv)
end

function fleaman_4_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function fleaman_4_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function fleaman_4_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
  if keys.target:IsMagicImmune() then return end
	if keys.target:HasModifier("fleaman_4_modifier_strip") then return end
	if self.parent:PassivesDisabled() then return end

	if RandomFloat(0, 100) < self.ability:GetSpecialValueFor("chance") then
    AddModifier(keys.target, self.caster, self.ability, "fleaman_4_modifier_strip", {
			duration = self.ability:GetSpecialValueFor("duration")
    }, true)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------