genuine_2_modifier_fallen = class({})

function genuine_2_modifier_fallen:IsHidden() return true end
function genuine_2_modifier_fallen:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function genuine_2_modifier_fallen:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self:ApplyDebuffs()
end

function genuine_2_modifier_fallen:OnRefresh(kv)
  self:ApplyDebuffs()
end

function genuine_2_modifier_fallen:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_fear", self.ability)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_debuff", self.ability)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_truesight", self.ability)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_break", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

function genuine_2_modifier_fallen:OnIntervalThink()
  local damage = self.parent:GetMaxHealth() * self.ability:GetSpecialValueFor("special_damage") * 0.01
  if damage == 0 then self:StartIntervalThink(-1) return end

  ApplyDamage({
    victim = self.parent, attacker = self.caster,
    damage_type = self.ability:GetAbilityDamageType(),
    damage = damage, ability = self.ability
  })

  if IsServer() then self:StartIntervalThink(1) end
end

-- UTILS -----------------------------------------------------------

function genuine_2_modifier_fallen:ApplyDebuffs()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_fear", self.ability)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_debuff", self.ability)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_truesight", self.ability)
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_break", self.ability)

  AddModifier(self.parent, self.ability, "_modifier_fear", {special = 1}, false)

  local slow = self.ability:GetSpecialValueFor("special_slow")
  if slow > 0 then AddModifier(self.parent, self.ability, "_modifier_movespeed_debuff", {percent = slow}, false) end

  if self.ability:GetSpecialValueFor("special_invi_break") == 1 then
    RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_invisible", nil)
    AddModifier(self.parent, self.ability, "_modifier_truesight", {}, false)
    AddModifier(self.parent, self.ability, "_modifier_break", {}, false)
  end

  if IsServer() then
    self:PlayEfxStart()
    self:OnIntervalThink()
  end
end

-- EFFECTS -----------------------------------------------------------

function genuine_2_modifier_fallen:PlayEfxStart()
  local particle_cast = "particles/genuine/genuine_fallen_hit.vpcf"
  local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
  ParticleManager:ReleaseParticleIndex(effect_cast)
end