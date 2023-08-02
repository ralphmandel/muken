dasdingo_2_modifier_aura_effect = class({})

function dasdingo_2_modifier_aura_effect:IsHidden() return false end
function dasdingo_2_modifier_aura_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function dasdingo_2_modifier_aura_effect:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
end

function dasdingo_2_modifier_aura_effect:OnRefresh(kv)
end

function dasdingo_2_modifier_aura_effect:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function dasdingo_2_modifier_aura_effect:CheckState()
	local state = {
		[MODIFIER_STATE_ALLOW_PATHING_THROUGH_TREES] = true
	}

	return state
end

function dasdingo_2_modifier_aura_effect:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}

	return funcs
end

function dasdingo_2_modifier_aura_effect:GetModifierConstantHealthRegen(keys)
  return self:GetAbility():GetSpecialValueFor("hp_regen")
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------