fleaman_2_modifier_passive = class({})
local tempTable = require("libraries/tempTable")

function fleaman_2_modifier_passive:IsHidden() return false end
function fleaman_2_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function fleaman_2_modifier_passive:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	if IsServer() then self:SetStackCount(0) end
end

function fleaman_2_modifier_passive:OnRefresh(kv)
end

function fleaman_2_modifier_passive:OnRemoved()
	RemoveBonus(self.ability, "DEX", self.parent)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_buff", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

function fleaman_2_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function fleaman_2_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
  if self.parent:PassivesDisabled() then return end

  if IsServer() then self:IncrementStackCount() end
  
  AddModifier(self.parent, self.ability, "fleaman_2_modifier_speed_stack", {
    duration = self.ability:GetSpecialValueFor("stack_duration"), modifier = tempTable:AddATValue(self)
  }, true)
end

function fleaman_2_modifier_passive:OnStackCountChanged(old)
  RemoveBonus(self.ability, "DEX", self.parent)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_buff", self.ability)

  AddBonus(self.ability, "DEX", self.parent, self:GetStackCount() * self.ability:GetSpecialValueFor("dex"), 0, nil)

  if self:GetStackCount() > 0 then
    AddModifier(self.parent, self.ability, "_modifier_movespeed_buff", {
      percent = self:GetStackCount() * self.ability:GetSpecialValueFor("ms")
    }, false)
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------