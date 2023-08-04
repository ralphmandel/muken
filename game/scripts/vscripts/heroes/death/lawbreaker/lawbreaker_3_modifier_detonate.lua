lawbreaker_3_modifier_detonate = class({})

function lawbreaker_3_modifier_detonate:IsHidden() return true end
function lawbreaker_3_modifier_detonate:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function lawbreaker_3_modifier_detonate:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  local delay = self.ability:GetSpecialValueFor("delay")
  self.radius = self.ability:GetAOERadius()
  self.id = kv.id

  if IsServer() then
    AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), self.radius, delay + 1, false)
    self:StartIntervalThink(delay)
  end
end

function lawbreaker_3_modifier_detonate:OnRefresh(kv)
end

function lawbreaker_3_modifier_detonate:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function lawbreaker_3_modifier_detonate:OnIntervalThink()
  self:DetonadeGrenade()
  self:Destroy()
end

-- UTILS -----------------------------------------------------------

function lawbreaker_3_modifier_detonate:DetonadeGrenade()
  if IsServer() then self.parent:EmitSound("Hero_Sniper.ConcussiveGrenade") end
  GridNav:DestroyTreesAroundPoint(self.parent:GetOrigin(), self.radius, false)

  if self.ability.projectiles[self.id].pfx then ParticleManager:DestroyParticle(self.ability.projectiles[self.id].pfx, false) end
  self.ability.projectiles[self.id] = nil

  local enemies = FindUnitsInRadius(
    self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.radius,
    self.ability:GetAbilityTargetTeam(), self.ability:GetAbilityTargetType(),
    self.ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false
  )

  for _,enemy in pairs(enemies) do
    if enemy:IsMagicImmune() == false then
      AddModifier(enemy, self.ability, "_modifier_percent_movespeed_debuff", {
        duration = 0.5, percent = 100
      }, true)

      AddModifier(enemy, self.ability, "lawbreaker_3_modifier_grenade", {
        duration = self.ability:GetSpecialValueFor("duration")
      }, true)
    end

    if IsServer() then enemy:EmitSound("Hero_Muerta.DeadShot.Damage") end

    ApplyDamage({
      victim = enemy, attacker = self.caster, ability = self.ability,
      damage = self.ability:GetSpecialValueFor("damage"),
      damage_type = self.ability:GetAbilityDamageType()
    })
  end
end

-- EFFECTS -----------------------------------------------------------