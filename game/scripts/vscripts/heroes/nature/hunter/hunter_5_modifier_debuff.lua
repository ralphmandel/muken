hunter_5_modifier_debuff = class({})

function hunter_5_modifier_debuff:IsHidden() return true end
function hunter_5_modifier_debuff:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_5_modifier_debuff:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  AddBonus(self.ability, "DEF", self.parent, 0, self.ability:GetSpecialValueFor("base_def"), nil)

  self:SetDebuffs(true)
end

function hunter_5_modifier_debuff:OnRefresh(kv)
  self:SetDebuffs(true)
end

function hunter_5_modifier_debuff:OnRemoved()
  self:SetDebuffs(false)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

function hunter_5_modifier_debuff:SetDebuffs(bEnabled)
  RemoveBonus(self.ability, "DEF", self.parent)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_root", self.ability)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_bleeding", self.ability)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_debuff", self.ability)

  if bEnabled == true then
    AddModifier(self.parent, self.ability, "_modifier_bleeding", {}, false)

    AddModifier(self.parent, self.ability, "_modifier_root", {
      duration = self.ability:GetSpecialValueFor("root_duration"), effect = 9
    }, true)
  end
end

-- EFFECTS -----------------------------------------------------------

function hunter_5_modifier_debuff:GetEffectName()
	return "particles/items3_fx/star_emblem.vpcf"
end

function hunter_5_modifier_debuff:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end