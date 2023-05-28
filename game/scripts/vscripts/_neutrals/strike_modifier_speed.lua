strike_modifier_speed = class({})

function strike_modifier_speed:IsHidden()
	return true
end

function strike_modifier_speed:IsPurgable()
    return false
end

function strike_modifier_speed:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

  self.parent:RemoveModifierByName("strike_modifier_slow")
  self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {percent = 150})
  AddBonus(self.ability, "_2_DEX", self.parent, 100, 0, nil)

  if IsServer() then self.parent:EmitSound("Ability.Windrun") end
end

function strike_modifier_speed:OnRefresh( kv )
end

function strike_modifier_speed:OnRemoved()
  if IsServer() then self.parent:StopSound("Ability.Windrun") end

  RemoveBonus(self.ability, "_2_DEX", self.parent)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_buff", self.ability)
end

----------------------------------------------------------------

function strike_modifier_speed:GetEffectName()
	return "particles/units/heroes/hero_windrunner/windrunner_windrun.vpcf"
end

function strike_modifier_speed:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end