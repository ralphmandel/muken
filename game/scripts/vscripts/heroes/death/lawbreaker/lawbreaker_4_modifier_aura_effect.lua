lawbreaker_4_modifier_aura_effect = class({})

function lawbreaker_4_modifier_aura_effect:IsHidden() return true end
function lawbreaker_4_modifier_aura_effect:IsPurgable() return false end
function lawbreaker_4_modifier_aura_effect:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

-- CONSTRUCTORS -----------------------------------------------------------

function lawbreaker_4_modifier_aura_effect:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.radius = self.ability:GetAOERadius()
  self.interval = self.ability:GetSpecialValueFor("interval")

  AddModifier(self.parent, self.ability, "_modifier_movespeed_debuff", {
    percent = self.ability:GetSpecialValueFor("slow")
  }, false)
  
  if IsServer() then self:OnIntervalThink() end
end

function lawbreaker_4_modifier_aura_effect:OnRefresh(kv)
end

function lawbreaker_4_modifier_aura_effect:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_debuff", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

function lawbreaker_4_modifier_aura_effect:OnIntervalThink()
  ApplyDamage({
    victim = self.parent, attacker = self.caster, ability = self.ability,
    damage = self.ability:GetSpecialValueFor("damage") * self.interval,
    damage_type = self.ability:GetAbilityDamageType()
  })

  if IsServer() then self:StartIntervalThink(self.interval) end
end

-- EFFECTS -----------------------------------------------------------