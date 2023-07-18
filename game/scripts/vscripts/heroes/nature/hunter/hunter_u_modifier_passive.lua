hunter_u_modifier_passive = class({})

function hunter_u_modifier_passive:IsHidden() return true end
function hunter_u_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_u_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function hunter_u_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function hunter_u_modifier_passive:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_BONUS_DAY_VISION,
    MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
	}

	return funcs
end

function hunter_u_modifier_passive:GetBonusDayVision()
	return self:GetAbility():GetSpecialValueFor("vision_range")
end

function hunter_u_modifier_passive:GetBonusNightVision()
	return self:GetAbility():GetSpecialValueFor("vision_range")
end

function hunter_u_modifier_passive:GetModifierAttackRangeBonus()
  return self:GetAbility():GetSpecialValueFor("atk_range")
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------