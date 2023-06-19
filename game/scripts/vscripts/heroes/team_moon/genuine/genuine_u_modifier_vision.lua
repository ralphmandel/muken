genuine_u_modifier_vision = class({})

function genuine_u_modifier_vision:IsHidden() return true end
function genuine_u_modifier_vision:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_u_modifier_vision:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function genuine_u_modifier_vision:OnRefresh(kv)
end

function genuine_u_modifier_vision:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_u_modifier_vision:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    MODIFIER_PROPERTY_BONUS_DAY_VISION
	}
	
	return funcs
end

function genuine_u_modifier_vision:GetBonusNightVision()
	return self:GetAbility():GetSpecialValueFor("night_vision")
end

function genuine_u_modifier_vision:GetBonusDayVision()
	return self:GetAbility():GetSpecialValueFor("special_day_vision")
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------