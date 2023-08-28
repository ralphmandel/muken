dasdingo_1_modifier_passive = class({})

function dasdingo_1_modifier_passive:IsHidden() return true end
function dasdingo_1_modifier_passive:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function dasdingo_1_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  -- AddModifier(self.parent, self.ability, "_modifier_heal_amp", {
  --   amount = self.ability:GetSpecialValueFor("heal_amp")
  -- }, false)
end

function dasdingo_1_modifier_passive:OnRefresh(kv)
  -- RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_heal_amp", self.ability)
  -- AddModifier(self.parent, self.ability, "_modifier_heal_amp", {
  --   amount = self.ability:GetSpecialValueFor("heal_amp")
  -- }, false)
end

function dasdingo_1_modifier_passive:OnRemoved(kv)
  --RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_heal_amp", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------