hunter_u_modifier_aim = class({})

function hunter_u_modifier_aim:IsHidden() return true end
function hunter_u_modifier_aim:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_u_modifier_aim:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function hunter_u_modifier_aim:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function hunter_u_modifier_aim:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_BONUS_DAY_VISION,
    MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
	}

	return funcs
end

function hunter_u_modifier_aim:GetBonusDayVision()
	return self:GetAbility():GetSpecialValueFor("vision_range")
end

function hunter_u_modifier_aim:GetBonusNightVision()
	return self:GetAbility():GetSpecialValueFor("vision_range")
end

function hunter_u_modifier_aim:GetModifierAttackRangeBonus()
  return self:GetAbility():GetSpecialValueFor("atk_range")
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------