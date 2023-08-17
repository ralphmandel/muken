hunter_4_modifier_debuff = class({})

function hunter_4_modifier_debuff:IsHidden() return false end
function hunter_4_modifier_debuff:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function hunter_4_modifier_debuff:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
  self.proj = {}

  AddModifier(self.parent, self.ability, "_modifier_movespeed_debuff", {
    duration = self:GetDuration(), percent = self.ability:GetSpecialValueFor("slow")
  }, false)

  if IsServer() then
    self.parent:EmitSound("hero_viper.PoisonAttack.Target")
    self:StartIntervalThink(1)
  end

  self.damageTable = {
    victim = self.parent, attacker = self.caster,
    damage = self.ability:GetSpecialValueFor("damage"),
    damage_type = self.ability:GetAbilityDamageType(),
    ability = self.ability, damage_flags = DOTA_DAMAGE_FLAG_NON_LETHAL
  }
end

function hunter_4_modifier_debuff:OnRefresh(kv)
  self.damageTable.damage = self.ability:GetSpecialValueFor("damage")
  AddModifier(self.parent, self.ability, "_modifier_movespeed_debuff", {
    duration = self:GetDuration(), percent = self.ability:GetSpecialValueFor("slow")
  }, false)

  if IsServer() then self.parent:EmitSound("hero_viper.PoisonAttack.Target") end
end

function hunter_4_modifier_debuff:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function hunter_4_modifier_debuff:OnIntervalThink()
  ApplyDamage(self.damageTable)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function hunter_4_modifier_debuff:GetEffectName()
	return "particles/units/heroes/hero_viper/viper_poison_debuff.vpcf"
end

function hunter_4_modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end