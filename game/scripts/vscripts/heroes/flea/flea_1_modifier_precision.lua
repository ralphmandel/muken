flea_1_modifier_precision = class({})
local tempTable = require("libraries/tempTable")

function flea_1_modifier_precision:IsHidden() return false end
function flea_1_modifier_precision:IsPurgable() return true end

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
	RemoveBonus(self.ability, "_1_AGI", self.parent)
	RemoveBonus(self.ability, "_2_DEX", self.parent)

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "flea_1_modifier_precision_status_efx", false) end
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_1_modifier_precision:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function flea_1_modifier_precision:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	self:BurnMana(keys.target)
end

function flea_1_modifier_precision:OnStackCountChanged(iStackCount)
	if iStackCount == self:GetStackCount() then return end

	if self:GetStackCount() > 0 then self:ApplyBuff() else self:Destroy() end
end

-- UTILS -----------------------------------------------------------

function flea_1_modifier_precision:AddMultStack()
	local duration = CalcStatus(self.ability:GetSpecialValueFor("duration"), self.caster, self.parent)
	self:SetDuration(duration, true)
	self:IncrementStackCount()

	local this = tempTable:AddATValue(self)
	self.parent:AddNewModifier(self.caster, self.ability, "flea_1_modifier_precision_stack", {
		duration = duration,
		modifier = this
	})
end

function flea_1_modifier_precision:ApplyBuff()
	local stats_base = self.ability:GetSpecialValueFor("stats_base")
	local stats_bonus = self.ability:GetSpecialValueFor("stats_bonus")

	local stats_total = stats_base + (stats_bonus * (self:GetStackCount() - 1))

	RemoveBonus(self.ability, "_1_AGI", self.parent)
	RemoveBonus(self.ability, "_2_DEX", self.parent)
	AddBonus(self.ability, "_1_AGI", self.parent, stats_total, 0, nil)
	AddBonus(self.ability, "_2_DEX", self.parent, stats_total, 0, nil)
end

function flea_1_modifier_precision:BurnMana(target)
	if target:IsAlive() == false then return end
	if target:IsMagicImmune() then return end

	local init_mana = target:GetMana()
	target:ReduceMana(init_mana * self.ability:GetSpecialValueFor("special_manaburn") * 0.01)
	local mana_burn = init_mana - target:GetMana()

	if mana_burn > 0 then
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, target, mana_burn, self.caster)
	end
end

-- EFFECTS -----------------------------------------------------------

function flea_1_modifier_precision:GetStatusEffectName()
    return "particles/status_fx/status_effect_slark_shadow_dance.vpcf"
end

function flea_1_modifier_precision:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end