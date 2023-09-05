hunter_2_modifier_debuff = class({})

function hunter_2_modifier_debuff:IsHidden() return false end
function hunter_2_modifier_debuff:IsPurgable() return true end
function hunter_2_modifier_debuff:GetAttributes() return MODIFIER_ATTRIBUTE_MULTIPLE end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_2_modifier_debuff:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.proj = {}

  self.damageTable = {
    victim = self.parent, attacker = self.caster,
    damage = self.ability:GetSpecialValueFor("poison_damage"),
    damage_type = self.ability:GetAbilityDamageType(),
    ability = self.ability, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL
  }

  if IsServer() then
    self.slow = AddModifier(self.parent, self.ability, "_modifier_movespeed_debuff", {
      percent = self.ability:GetSpecialValueFor("slow"), duration = self:GetDuration()
    }, false)

    self.parent:EmitSound("hero_viper.PoisonAttack.Target")
    self:StartIntervalThink(1)
  end
end

function hunter_2_modifier_debuff:OnRefresh(kv)
  self.damageTable.damage = self.ability:GetSpecialValueFor("poison_damage")
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_debuff", self.ability)
  AddModifier(self.parent, self.ability, "_modifier_movespeed_debuff", {percent = self.ability:GetSpecialValueFor("slow")}, false)

  if IsServer() then self.parent:EmitSound("hero_viper.PoisonAttack.Target") end
end

function hunter_2_modifier_debuff:OnRemoved()
  if IsServer() then self.slow:Destroy() end
end

-- API FUNCTIONS -----------------------------------------------------------

function hunter_2_modifier_debuff:OnIntervalThink()
  local interval = 1

  if self.parent:GetHealthPercent() > 25 then
    ApplyDamage(self.damageTable)
  else
    interval = 0.5
  end

  if IsServer() then self:StartIntervalThink(interval) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function hunter_2_modifier_debuff:GetEffectName()
	return "particles/units/heroes/hero_viper/viper_poison_debuff.vpcf"
end

function hunter_2_modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end