paladin_1_modifier_link_caster = class({})

function paladin_1_modifier_link_caster:IsHidden() return true end
function paladin_1_modifier_link_caster:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function paladin_1_modifier_link_caster:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function paladin_1_modifier_link_caster:OnRefresh(kv)
end

function paladin_1_modifier_link_caster:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function paladin_1_modifier_link_caster:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_STATUS_RESISTANCE_STACKING
	}

	return funcs
end

function paladin_1_modifier_link_caster:GetModifierStatusResistanceStacking()
  return self:GetAbility():GetSpecialValueFor("status_resist")
end


-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------