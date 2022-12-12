bald_3_modifier_passive = class({})
local tempTable = require("libraries/tempTable")

function bald_3_modifier_passive:IsHidden() return false end
function bald_3_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_3_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.hits = 0

	if IsServer() then self:SetStackCount(0) end
end

function bald_3_modifier_passive:OnRefresh(kv)
end

function bald_3_modifier_passive:OnRemoved()
	RemoveBonus(self.ability, "_1_CON", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_3_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function bald_3_modifier_passive:GetModifierAttackRangeBonus()
	return self.ability.atk_range
end

function bald_3_modifier_passive:OnAttackLanded(keys)
	if keys.target ~= self.parent then return end
	if self.parent:HasModifier("bald_3_modifier_inner") then return end
	if self.parent:PassivesDisabled() then return end
	if self.ability:IsCooldownReady() == false then return end

	self.hits = self.hits + 1

	if self.hits >= self.ability:GetSpecialValueFor("hits") then
		self:AddMultStack()
		self.hits = 0
	end
end

function bald_3_modifier_passive:OnStackCountChanged(old)
	local stack = self:GetStackCount()
	local max_stack = self.ability:GetSpecialValueFor("max_stack")
	if stack > max_stack then stack = max_stack end

	if stack >= max_stack / 2 then
		self.ability:SetCurrentAbilityCharges(4)
	else
		self.ability:SetCurrentAbilityCharges(2)
	end

	RemoveBonus(self.ability, "_1_CON", self.parent)

	if self:GetStackCount() > 0 then
		AddBonus(self.ability, "_1_CON", self.parent, stack, 0, nil)
	end
end

-- UTILS -----------------------------------------------------------

function bald_3_modifier_passive:AddMultStack()
	self:IncrementStackCount()

	local this = tempTable:AddATValue(self)
	self.parent:AddNewModifier(self.caster, self.ability, "bald_3_modifier_passive_stack", {
		duration = self.ability:GetSpecialValueFor("stack_duration"),
		modifier = this
	})
end

-- EFFECTS -----------------------------------------------------------