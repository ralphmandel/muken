flea_5_modifier_passive = class({})

function flea_5_modifier_passive:IsHidden()
	return true
end

function flea_5_modifier_passive:IsPurgable()
	return false
end

function flea_5_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_5_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function flea_5_modifier_passive:OnRefresh(kv)
end

function flea_5_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function flea_5_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_PRE_ATTACK,
		MODIFIER_PROPERTY_PREATTACK_BONUS_DAMAGE_POST_CRIT,
	}

	return funcs
end

function flea_5_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if self.parent:PassivesDisabled() then return end
	if keys.target:HasModifier("flea_5_modifier_desolator") then return end

	local chance = self.ability:GetSpecialValueFor("chance")
	local duration = self.ability:GetSpecialValueFor("duration")

	if RandomFloat(1, 100) <= chance then
		keys.target:AddNewModifier(self.caster, self.ability, "flea_5_modifier_desolator", {
			duration = self.ability:CalcStatus(duration, self.caster, keys.target)
		})
	end
end

function flea_5_modifier_passive:GetModifierPreAttack(keys)
	if keys.target:HasModifier("flea_5_modifier_desolator") == false then return end

	print(keys.target:GetPhysicalArmorValue(false), "armor")
	self.ability:AddBonus("_2_DEF", keys.target, -9999, 0, nil)
	print(keys.target:GetPhysicalArmorValue(false), "armor")
end

function flea_5_modifier_passive:GetModifierPreAttack_BonusDamagePostCrit(keys)
	--if keys.attacker ~= self.parent then return end

	self.ability:RemoveBonus("_2_DEF", keys.target)
	print(keys.target:GetPhysicalArmorValue(false), "armor2")
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------