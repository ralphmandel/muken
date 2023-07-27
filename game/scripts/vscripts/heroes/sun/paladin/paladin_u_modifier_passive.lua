paladin_u_modifier_passive = class({})

function paladin_u_modifier_passive:IsHidden() return true end
function paladin_u_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function paladin_u_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  AddBonus(self.ability, "CON", self.parent, 0, self.ability:GetSpecialValueFor("con"), nil)
end

function paladin_u_modifier_passive:OnRefresh(kv)
end

function paladin_u_modifier_passive:OnRemoved()
  RemoveBonus(self.ability, "CON", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function paladin_u_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}

	return funcs
end

function paladin_u_modifier_passive:GetModifierIncomingDamage_Percentage(keys)
  if keys.damage_type == DAMAGE_TYPE_PURE then
    return self:GetAbility():GetSpecialValueFor("holy_reduction")
  end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------