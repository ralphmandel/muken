druid_3_modifier_totem_effect = class({})

function druid_3_modifier_totem_effect:IsHidden()
	if self:GetParent():GetUnitName() == "druid_totem" then return true end
	return false
end

function druid_3_modifier_totem_effect:IsPurgable()
	return false
end

-----------------------------------------------------------

function druid_3_modifier_totem_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if self.parent:GetUnitName() == "druid_totem" then return end

	local atkspeed = 0
	local recovery = 0
	local bonus = self.ability:GetSpecialValueFor("bonus")

	-- UP 3.21
	if self.ability:GetRank(21) then
		self.ability:AddBonus("_1_AGI", self.parent, 12, 0, nil)
		atkspeed = 25
	end

	-- UP 3.22
	if self.ability:GetRank(22) then
		self.ability:AddBonus("_2_REC", self.parent, 5, 0, nil)
		recovery = 1.5
		bonus = bonus + 5
	end

	self.atkspeed_creature = atkspeed
	self.recovery_creature = recovery
	self.resist_creature = bonus

	self.ability:AddBonus("_2_RES", self.parent, bonus, 0, nil)
	self.ability:AddBonus("_2_MND", self.parent, bonus, 0, nil)
end

function druid_3_modifier_totem_effect:OnRefresh(kv)
end

function druid_3_modifier_totem_effect:OnRemoved(kv)
	self.ability:RemoveBonus("_2_RES", self.parent)
	self.ability:RemoveBonus("_2_MND", self.parent)
	self.ability:RemoveBonus("_2_REC", self.parent)
	self.ability:RemoveBonus("_1_AGI", self.parent)
end

-----------------------------------------------------------

function druid_3_modifier_totem_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACKSPEED_PERCENTAGE,
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT,
		MODIFIER_PROPERTY_MAGICAL_RESISTANCE_BONUS
	}

	return funcs
end

function druid_3_modifier_totem_effect:GetModifierAttackSpeedPercentage()
	if self:GetParent():IsHero() == false then
		return self.atkspeed_creature
	end

	return 0
end

function druid_3_modifier_totem_effect:GetModifierConstantManaRegen()
	if self:GetParent():IsHero() == false then
		return self.recovery_creature
	end

	return 0
end


function druid_3_modifier_totem_effect:GetModifierMagicalResistanceBonus()
	if self:GetParent():IsHero() == false then
		return self.resist_creature
	end

	return 0
end

-----------------------------------------------------------