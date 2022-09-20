osiris_1_modifier_poison = class ({})
local tempTable = require("libraries/tempTable")

function osiris_1_modifier_poison:IsHidden()
    return false
end

function osiris_1_modifier_poison:IsPurgable()
    return true
end

function osiris_1_modifier_poison:IsDebuff()
    return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function osiris_1_modifier_poison:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.tick = self.ability:GetSpecialValueFor("tick")
	self.heal_degen = self.ability:GetSpecialValueFor("base_heal_degen")

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "osiris_1_modifier_poison_status_efx", true) end

	if IsServer() then
		self:SetStackCount(0)
		self:AddMultStack()
		self:StartIntervalThink(self.tick)
		self:PlayEfxRelease(true)
	end
end

function osiris_1_modifier_poison:OnRefresh(kv)
	if IsServer() then
		self:AddMultStack()
		self:PlayEfxRelease(false)
	end
end

function osiris_1_modifier_poison:OnRemoved(kv)
	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "osiris_1_modifier_poison_status_efx", false) end
end

-- API FUNCTIONS -----------------------------------------------------------

function osiris_1_modifier_poison:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEAL_AMPLIFY_PERCENTAGE_TARGET,
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE
	}

	return funcs
end

function osiris_1_modifier_poison:GetModifierHealAmplify_PercentageTarget()
    return -self.heal_degen
end

function osiris_1_modifier_poison:GetModifierHPRegenAmplify_Percentage()
    return -self.heal_degen
end

function osiris_1_modifier_poison:OnIntervalThink()
	local percent = self.parent:GetHealthPercent() * 0.01
	if percent >= self.ability:GetSpecialValueFor("poison_cap") * 0.01 then
		ApplyDamage({
			attacker = self.caster, victim = self.parent, damage = self.poison_damage * self.tick * percent,
			ability = self.ability, damage_type = self.ability:GetAbilityDamageType()
		})		
	end

	if IsServer() then self:StartIntervalThink(self.tick) end
end

function osiris_1_modifier_poison:OnStackCountChanged(old)
	local base_poison_damage = self.ability:GetSpecialValueFor("base_poison_damage")
	self.poison_damage = base_poison_damage
	--local base_heal_degen = self.ability:GetSpecialValueFor("base_heal_degen")
	--self.heal_degen = 0

	if self:GetStackCount() > 1 then
		for i = 1, self:GetStackCount() - 1, 1 do
			self.poison_damage = self.poison_damage * (1 + (base_poison_damage * 0.01))
			--self.heal_degen = self.heal_degen + ((100 - self.heal_degen) * base_heal_degen * 0.01)
		end
	end
end

-- UTILS -----------------------------------------------------------

function osiris_1_modifier_poison:AddMultStack()
	self:IncrementStackCount()

	local this = tempTable:AddATValue(self)
	self.parent:AddNewModifier(self.caster, self.ability, "osiris_1_modifier_poison_stack", {
		duration = self:GetDuration(),
		modifier = this
	})
end

-- EFFECTS -----------------------------------------------------------

function osiris_1_modifier_poison:GetEffectName()
	return "particles/osiris/poison_debuff_alt/osiris_poison_debuff.vpcf"
end

function osiris_1_modifier_poison:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end

function osiris_1_modifier_poison:GetStatusEffectName()
	return "particles/osiris/poison_debuff_alt/osiris_poison_status_efx.vpcf"
end

function osiris_1_modifier_poison:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end

function osiris_1_modifier_poison:PlayEfxRelease(bStart)
	if IsServer() then self.parent:EmitSound("Hero_Venomancer.VenomousGaleImpact") end
end