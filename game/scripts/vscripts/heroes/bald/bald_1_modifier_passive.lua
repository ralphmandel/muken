bald_1_modifier_passive = class({})
local tempTable = require("libraries/tempTable")

function bald_1_modifier_passive:IsHidden() return false end
function bald_1_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_1_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:SetStackCount(0) end
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
		self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
		self:AddMultStack()
	end
end

function bald_1_modifier_passive:OnStackCountChanged(old)
	self.ability:RemoveBonus("_1_STR", self.parent)

	if self:GetStackCount() > 0 then
		self.ability:AddBonus("_1_STR", self.parent, self:GetStackCount(), 0, nil)
	end
end

-- UTILS -----------------------------------------------------------

function bald_1_modifier_passive:AddMultStack()
	local duration = self.ability:GetSpecialValueFor("duration")

	self:IncrementStackCount()

	local this = tempTable:AddATValue(self)
	self.parent:AddNewModifier(self.caster, self.ability, "bald_1_modifier_passive_stack", {
		duration = duration,
		modifier = this
	})
end

-- EFFECTS -----------------------------------------------------------