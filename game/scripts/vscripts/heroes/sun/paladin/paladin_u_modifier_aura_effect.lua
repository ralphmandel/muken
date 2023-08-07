paladin_u_modifier_aura_effect = class({})

function paladin_u_modifier_aura_effect:IsHidden() return false end
function paladin_u_modifier_aura_effect:IsPurgable() return false end
function paladin_u_modifier_aura_effect:RemoveOnDeath() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function paladin_u_modifier_aura_effect:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function paladin_u_modifier_aura_effect:OnRefresh(kv)
end

function paladin_u_modifier_aura_effect:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function paladin_u_modifier_aura_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}

	return funcs
end

function paladin_u_modifier_aura_effect:GetModifierIncomingDamage_Percentage(keys)
  if keys.damage_type == DAMAGE_TYPE_PURE and self:GetCaster():PassivesDisabled() == false then
    return self:GetAbility():GetSpecialValueFor("holy_reduction")
  end

  return 0
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------