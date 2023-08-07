icebreaker__modifier_slow = class({})

function icebreaker__modifier_slow:IsHidden() return false end
function icebreaker__modifier_slow:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function icebreaker__modifier_slow:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  if IsServer() then self:SetStackCount(kv.stack) end
end

function icebreaker__modifier_slow:OnRefresh(kv)
  if IsServer() then self:SetStackCount(kv.stack) end
end

function icebreaker__modifier_slow:OnRemoved()
  self.parent:RemoveModifierByNameAndCaster("_modifier_bat_increased", self.caster)
  self.parent:RemoveModifierByNameAndCaster("_modifier_percent_movespeed_debuff", self.caster)
end

-- API FUNCTIONS -----------------------------------------------------------

function icebreaker__modifier_slow:OnStackCountChanged(old)
  self.parent:RemoveModifierByNameAndCaster("_modifier_bat_increased", self.caster)
  AddModifier(self.parent, self.ability, "_modifier_bat_increased", {
    amount = self:GetStackCount() * self.ability:GetSpecialValueFor("slow_as")
  }, false)

  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_percent_movespeed_debuff", self.ability)
  AddModifier(self.parent, self.ability, "_modifier_percent_movespeed_debuff", {
    percent = self:GetStackCount() * self.ability:GetSpecialValueFor("slow_ms")
  }, false)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function icebreaker__modifier_slow:GetEffectName()
	return "particles/units/heroes/hero_abaddon/abaddon_curse_frostmourne_debuff.vpcf"
end

function icebreaker__modifier_slow:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end