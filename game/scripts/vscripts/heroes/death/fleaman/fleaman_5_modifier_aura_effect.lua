fleaman_5_modifier_aura_effect = class({})

function fleaman_5_modifier_aura_effect:IsHidden() return true end
function fleaman_5_modifier_aura_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function fleaman_5_modifier_aura_effect:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if self.caster:GetTeamNumber() == self.parent:GetTeamNumber() then
    self.parent:RemoveModifierByName("fleaman_5_modifier_shadow")
    AddModifier(self.parent, self.ability, "fleaman_5_modifier_shadow", {}, false)
  else
    AddModifier(self.parent, self.ability, "_modifier_no_vision_attacker", {}, false)

    AddModifier(self.parent, self.ability, "_modifier_percent_movespeed_debuff", {
      percent = self.ability:GetSpecialValueFor("slow_percent")
    }, false)

    AddModifier(self.parent, self.ability, "_modifier_blind", {
      percent = self.ability:GetSpecialValueFor("blind")
    }, false)
  end  
end

function fleaman_5_modifier_aura_effect:OnRefresh(kv)
end

function fleaman_5_modifier_aura_effect:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_no_vision_attacker", self.ability)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_percent_movespeed_debuff", self.ability)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_blind", self.ability)

  if self.caster:GetTeamNumber() == self.parent:GetTeamNumber() then
    -- AddModifier(self.parent, self.ability, "_modifier_invisible", {
    --   delay = 0.5, attack_break = 0
    -- }, false)

    AddModifier(self.parent, self.ability, "fleaman_5_modifier_shadow", {
      duration = self.ability:GetSpecialValueFor("delay")
    }, true)
  end
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------