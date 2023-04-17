strike_modifier_slow = class({})

function strike_modifier_slow:IsHidden()
	return true
end

function strike_modifier_slow:IsPurgable()
    return false
end

function strike_modifier_slow:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  self.parent:RemoveModifierByName("strike_modifier_speed")
  self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {percent = 50})
end

function strike_modifier_slow:OnRefresh( kv )
end

function strike_modifier_slow:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_debuff", self.ability)
end