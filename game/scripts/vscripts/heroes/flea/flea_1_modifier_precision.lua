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
	self.ability:RemoveBonus("_2_LCK", self.parent)

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "flea_1_modifier_precision_status_efx", false) end
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_1_modifier_precision:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function flea_1_modifier_precision:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end

	-- UP 1.21
	if self.ability:GetRank(21) then
		self:BurnMana(keys.target)
	end
end

function flea_1_modifier_precision:OnStackCountChanged(iStackCount)
	if iStackCount == self:GetStackCount() then return end

	if self:GetStackCount() > 0 then self:ApplyBuff() else self:Destroy() end
end

-- UTILS -----------------------------------------------------------

function flea_1_modifier_precision:AddMultStack()
	local duration = self.ability:CalcStatus(self.ability:GetSpecialValueFor("duration"), self.caster, self.parent)
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

	self.ability:RemoveBonus("_1_AGI", self.parent)
	self.ability:RemoveBonus("_2_DEX", self.parent)
	self.ability:RemoveBonus("_2_LCK", self.parent)
	self.ability:AddBonus("_1_AGI", self.parent, stats_total, 0, nil)
	self.ability:AddBonus("_2_DEX", self.parent, stats_total, 0, nil)

	-- UP 1.31
	if self.ability:GetRank(31) then
		self.ability:AddBonus("_2_LCK", self.parent, stats_total, 0, nil)
	end
end

function flea_1_modifier_precision:BurnMana(target)
	if target:IsAlive() == false then return end
	if target:IsMagicImmune() then return end

	local init_mana = target:GetMana()
	target:ReduceMana(init_mana * 0.03)
	local mana_burn = init_mana - target:GetMana()

	if mana_burn > 0 then
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_MANA_LOSS, target, mana_burn, self.caster)

		-- ApplyDamage({
		-- 	damage = mana_burn * 0.5,
        --     attacker = self.caster,
        --     victim = target,
        --     damage_type = DAMAGE_TYPE_MAGICAL,
        --     ability = self.ability
		-- })
	end
end

-- EFFECTS -----------------------------------------------------------

function flea_1_modifier_precision:GetStatusEffectName()
    return "particles/status_fx/status_effect_slark_shadow_dance.vpcf"
end

function flea_1_modifier_precision:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end