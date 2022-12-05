bald_3_modifier_passive = class({})
local tempTable = require("libraries/tempTable")

function bald_3_modifier_passive:IsHidden() return false end
function bald_3_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_3_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:SetStackCount(0) end
end

function bald_3_modifier_passive:OnRefresh(kv)
end

function bald_3_modifier_passive:OnRemoved()
	self.ability:RemoveBonus("_1_CON", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_3_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function bald_3_modifier_passive:OnAttackLanded(keys)
	if keys.target ~= self.parent then return end
	if self.parent:HasModifier("bald_3_modifier_inner") then return end
	if self.parent:PassivesDisabled() then return end

	local chance = self.ability:GetSpecialValueFor("creep_chance")
	if keys.attacker:IsHero() then chance = self.ability:GetSpecialValueFor("hero_chance") end

	if RandomFloat(1, 100) <= chance then
		self:AddMultStack()
	end
end

function bald_3_modifier_passive:OnStackCountChanged(old)
	local behavior = 1
	local min_stack = self.ability:GetSpecialValueFor("min_stack")

	self.ability:RemoveBonus("_1_CON", self.parent)

	if self:GetStackCount() >= min_stack then
		self.ability:AddBonus("_1_CON", self.parent, self:GetStackCount(), 0, nil)
		behavior = 2
	end

	self.ability:CheckAbilityCharges(behavior)
end

-- UTILS -----------------------------------------------------------

function bald_3_modifier_passive:AddMultStack()
	local duration = self.ability:GetSpecialValueFor("stack_duration")
	self:IncrementStackCount()

	local this = tempTable:AddATValue(self)
	self.parent:AddNewModifier(self.caster, self.ability, "bald_3_modifier_passive_stack", {
		duration = duration,
		modifier = this
	})
end

-- EFFECTS -----------------------------------------------------------