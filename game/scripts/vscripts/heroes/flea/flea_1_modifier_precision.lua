flea_1_modifier_precision = class({})
local tempTable = require("libraries/tempTable")

function flea_1_modifier_precision:IsHidden()
	return false
end

function flea_1_modifier_precision:IsPurgable()
	return true
end

function flea_1_modifier_precision:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_1_modifier_precision:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "flea_1_modifier_precision_status_efx", true) end

	if IsServer() then
		self:SetStackCount(0)
		self:AddMultStack()
	end
end

function flea_1_modifier_precision:OnRefresh(kv)
	if IsServer() then
		self:AddMultStack()
	end
end

function flea_1_modifier_precision:OnRemoved()
	self.ability:RemoveBonus("_1_AGI", self.parent)
	self.ability:RemoveBonus("_2_DEX", self.parent)

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "flea_1_modifier_precision_status_efx", false) end
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_1_modifier_precision:OnStackCountChanged(iStackCount)
	if iStackCount == self:GetStackCount() then return end

	if self:GetStackCount() > 0 then self:ApplyBuff() else self:Destroy() end
end

-- UTILS -----------------------------------------------------------

function flea_1_modifier_precision:AddMultStack()
	local duration = self.ability:GetSpecialValueFor("duration")
	self:IncrementStackCount()

	local this = tempTable:AddATValue(self)
	self.parent:AddNewModifier(self.caster, self.ability, "flea_1_modifier_precision_stack", {
		duration = self.ability:CalcStatus(duration, self.caster, self.parent),
		modifier = this
	})
end

function flea_1_modifier_precision:ApplyBuff()
	local stats_base = self.ability:GetSpecialValueFor("stats_base")
	local stats_bonus = self.ability:GetSpecialValueFor("stats_bonus")

	local stats_total = stats_base + (stats_bonus * (self:GetStackCount() - 1))

	self.ability:RemoveBonus("_1_AGI", self.parent)
	self.ability:RemoveBonus("_2_DEX", self.parent)
	self.ability:AddBonus("_1_AGI", self.parent, stats_total, 0, nil)
	self.ability:AddBonus("_2_DEX", self.parent, stats_total, 0, nil)
end

-- EFFECTS -----------------------------------------------------------

function flea_1_modifier_precision:GetStatusEffectName()
    return "particles/status_fx/status_effect_slark_shadow_dance.vpcf"
end

function flea_1_modifier_precision:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end