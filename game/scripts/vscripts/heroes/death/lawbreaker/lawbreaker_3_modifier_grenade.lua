lawbreaker_3_modifier_grenade = class({})

function lawbreaker_3_modifier_grenade:IsHidden() return false end
function lawbreaker_3_modifier_grenade:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function lawbreaker_3_modifier_grenade:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  
  AddBonus(self.ability, "_2_DEF", self.parent, self.ability:GetSpecialValueFor("def"), 0, nil)
  AddModifier(self.parent, self.caster, self.ability, "_modifier_blind", {
    percent = self.ability:GetSpecialValueFor("blind")
  }, false)

  if IsServer() then self.parent:EmitSound("Hero_Muerta.DeadShot.Slow") end
end

function lawbreaker_3_modifier_grenade:OnRefresh(kv)
  if IsServer() then self.parent:EmitSound("Hero_Muerta.DeadShot.Slow") end
end

function lawbreaker_3_modifier_grenade:OnRemoved()
  RemoveBonus(self.ability, "_2_DEF", self.parent)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_blind", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function lawbreaker_3_modifier_grenade:GetEffectName()
	return "particles/lawbreaker/grenade/lawbreaker_grenade_slow.vpcf"
end

function lawbreaker_3_modifier_grenade:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end