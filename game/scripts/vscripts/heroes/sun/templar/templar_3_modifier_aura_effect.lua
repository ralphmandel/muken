templar_3_modifier_aura_effect = class({})

function templar_3_modifier_aura_effect:IsHidden() return true end
function templar_3_modifier_aura_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function templar_3_modifier_aura_effect:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.interval = self.ability:GetSpecialValueFor("interval")
  
  if IsServer() then
    self.parent:EmitSound("Hero_AbyssalUnderlord.Pit.TargetHero")
    self:StartIntervalThink(self.interval)
  end
end

function templar_3_modifier_aura_effect:OnRefresh(kv)
end

function templar_3_modifier_aura_effect:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function templar_3_modifier_aura_effect:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_HEALTH_REGEN_CONSTANT
	}

	return funcs
end

function templar_3_modifier_aura_effect:GetModifierConstantHealthRegen(keys)
  if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
    return self:GetAbility():GetSpecialValueFor("hp_regen")
  end

  return 0
end

function templar_3_modifier_aura_effect:OnIntervalThink()
  if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then return end

  if IsServer() then self.parent:EmitSound("Templar.Circle.Hit") end

  ApplyDamage({
    victim = self.parent, attacker = self.caster,
    damage = self.ability:GetSpecialValueFor("damage") * self.interval,
    damage_type = self.ability:GetAbilityDamageType(),
    ability = self.ability
  })
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function templar_3_modifier_aura_effect:GetEffectName()
  if self:GetParent():GetTeamNumber() == self:GetCaster():GetTeamNumber() then
    return "particles/econ/items/omniknight/omniknight_fall20_immortal/omniknight_fall20_immortal_degen_aura_debuff.vpcf"
  else
    return "particles/econ/items/omniknight/omni_crimson_witness_2021/omniknight_crimson_witness_2021_degen_aura_debuff.vpcf"
  end
end

function templar_3_modifier_aura_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end