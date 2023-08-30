hunter_4_modifier_bandage = class({})

function hunter_4_modifier_bandage:IsHidden() return false end
function hunter_4_modifier_bandage:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_4_modifier_bandage:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.hp_regen = self.ability:GetSpecialValueFor("hp_regen")

  AddModifier(self.parent, self.ability, "_modifier_movespeed_buff", {percent = self.ability:GetSpecialValueFor("ms")}, false)
end

function hunter_4_modifier_bandage:OnRefresh(kv)
  self.hp_regen = self.ability:GetSpecialValueFor("hp_regen")
end

function hunter_4_modifier_bandage:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_buff", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

function hunter_4_modifier_bandage:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}

	return funcs
end

function hunter_4_modifier_bandage:GetModifierConstantHealthRegen(keys)
  return self.hp_regen
end

-- UTILS -----------------------------------------------------------


-- EFFECTS -----------------------------------------------------------

function hunter_4_modifier_bandage:GetEffectName()
	return "particles/items_fx/healing_tango.vpcf"
end

function hunter_4_modifier_bandage:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end