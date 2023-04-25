druid_1_modifier_root_aura_effect = class({})

function druid_1_modifier_root_aura_effect:IsHidden() return true end
function druid_1_modifier_root_aura_effect:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_1_modifier_root_aura_effect:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.parent:AddNewModifier(self.caster, self.ability, "_modifier_root", {effect = 5})

  if self.ability:GetSpecialValueFor("special_disarm") == 1 then
    self.parent:AddNewModifier(self.caster, self.ability, "_modifier_disarm", {})
  end

  if self.ability:GetSpecialValueFor("special_silence") == 1 then
    self.parent:AddNewModifier(self.caster, self.ability, "_modifier_silence", {})
  end
end

function druid_1_modifier_root_aura_effect:OnRefresh(kv)
end

function druid_1_modifier_root_aura_effect:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_root", self.ability)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_disarm", self.ability)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_silence", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------