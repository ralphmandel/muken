fleaman_5_modifier_passive = class({})

function fleaman_5_modifier_passive:IsHidden() return false end
function fleaman_5_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function fleaman_5_modifier_passive:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	if IsServer() then self:SetStackCount(0) end
end

function fleaman_5_modifier_passive:OnRefresh(kv)
end

function fleaman_5_modifier_passive:OnRemoved()
	RemoveBonus(self.ability, "_1_STR", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function fleaman_5_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function fleaman_5_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
  if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self.parent:PassivesDisabled() then return end

  AddModifier(keys.target, self.caster, self.ability, "fleaman_5_modifier_steal", {
    duration = self.ability:GetSpecialValueFor("stack_duration")
  }, true)
end

function fleaman_5_modifier_passive:OnStackCountChanged(old)
	RemoveBonus(self.ability, "_1_STR", self.parent)
  AddBonus(self.ability, "_1_STR", self.parent, self:GetStackCount(), 0, nil)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------