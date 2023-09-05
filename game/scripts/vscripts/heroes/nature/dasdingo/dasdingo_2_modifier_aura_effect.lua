dasdingo_2_modifier_aura_effect = class({})

function dasdingo_2_modifier_aura_effect:IsHidden() return false end
function dasdingo_2_modifier_aura_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function dasdingo_2_modifier_aura_effect:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  AddModifier(self.parent, self.ability, "_modifier_truesight", {}, false)

  ApplyDamage({
    attacker = self.caster, victim = self.parent, ability = self.ability,
    damage = self.ability:GetSpecialValueFor("root_damage") * kv.multiplier,
    damage_type = self.ability:GetAbilityDamageType()
  })

  if self.parent:IsMagicImmune() == false then
    AddModifier(self.parent, self.ability, "_modifier_root", {
      duration = self.ability:GetSpecialValueFor("root_duration") * kv.multiplier, effect = 8
    }, true)
  end
end

function dasdingo_2_modifier_aura_effect:OnRefresh(kv)
  if self.parent:IsMagicImmune() == false then
    AddModifier(self.parent, self.ability, "_modifier_root", {
      duration = self.ability:GetSpecialValueFor("root_duration") * kv.multiplier, effect = 8
    }, true)
  end
end

function dasdingo_2_modifier_aura_effect:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_truesight", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------