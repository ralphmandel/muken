paladin_1_modifier_regen = class({})

function paladin_1_modifier_regen:IsHidden() return false end
function paladin_1_modifier_regen:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function paladin_1_modifier_regen:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function paladin_1_modifier_regen:OnRefresh(kv)
end

function paladin_1_modifier_regen:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function paladin_1_modifier_regen:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}

	return funcs
end

function paladin_1_modifier_regen:GetModifierConstantHealthRegen(keys)
  return self.ability:GetSpecialValueFor("regen")
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------