ancient_1_modifier_passive = class({})

function ancient_1_modifier_passive:IsHidden() return false end
function ancient_1_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_1_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

  local bat_percent = self.ability:GetSpecialValueFor("bat_percent")

  AddModifier(self.parent, self.ability, "_modifier_bat_increased", {
    amount = math.floor(BaseStats(self.parent):GetSpecialValueFor("base_attack_time") * bat_percent)
  }, false)
end

function ancient_1_modifier_passive:OnRefresh(kv)
end

function ancient_1_modifier_passive:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_bat_increased", self.ability)
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_1_modifier_passive:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_BASEDAMAGEOUTGOING_PERCENTAGE,
    MODIFIER_EVENT_ON_ATTACK,
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_EVENT_ON_ATTACKED,
		MODIFIER_EVENT_ON_TAKEDAMAGE,
	}

	return funcs
end

function ancient_1_modifier_passive:GetModifierBaseDamageOutgoing_Percentage(keys)
  return self:GetAbility():GetSpecialValueFor("damage_percent")
end

function ancient_1_modifier_passive:OnAttack(keys)
	if keys.attacker ~= self.parent then return end
  if self.parent:PassivesDisabled() then return end

  AddModifier(keys.target, self.ability, "_modifier_no_block", {duration = 0.5}, false)
end

function ancient_1_modifier_passive:OnAttackFail(keys)
	if keys.attacker ~= self.parent then return end
  RemoveAllModifiersByNameAndAbility(keys.target, "_modifier_no_block", self.ability)
end

function ancient_1_modifier_passive:OnAttacked(keys)
	if keys.attacker ~= self.parent then return end
  RemoveAllModifiersByNameAndAbility(keys.target, "_modifier_no_block", self.ability)

	if self.parent:PassivesDisabled() then return end

<<<<<<< Updated upstream
  if BaseStats(keys.attacker).has_crit then
    self:PlayEfxCrit(keys.attacker, true)
=======
  if BaseStats(keys.attacker).has_crit == true then
    self:PlayEfxCrit(keys.attacker, keys.original_damage, "Ancient.Stun.Crit")
>>>>>>> Stashed changes
    if keys.target:GetPlayerOwner() then
      self:PlayEfxCrit(keys.target, keys.original_damage, "Ancient.Stun.Crit")
    end
  end

  self:ApplyStun(keys.target, keys.original_damage, self.ability)
end

function ancient_1_modifier_passive:OnTakeDamage(keys)
  if keys.attacker == nil then return end
  if IsValidEntity(keys.attacker) == false then return end
	if keys.attacker ~= self.parent then return end
  if keys.damage_category ~= DOTA_DAMAGE_CATEGORY_SPELL then return end
  if keys.damage_type ~= DAMAGE_TYPE_PHYSICAL then return end
	if self.parent:PassivesDisabled() then return end

  local sound = "Ancient.Stun.Crit"
  local ability = nil

  if keys.inflictor then
    if keys.inflictor:GetClassname() == "ability_lua" then
      ability = keys.inflictor
      if keys.inflictor:GetAbilityName() == "ancient_3__roar" then
        sound = "Hero_PrimalBeast.Uproar.Projectile.Split"
      end
    end
  end

  self:PlayEfxCrit(keys.unit, keys.original_damage, sound)
  self:ApplyStun(keys.unit, keys.original_damage, ability)
end

-- UTILS -----------------------------------------------------------

function ancient_1_modifier_passive:ApplyStun(target, damage, ability)
  if target:IsMagicImmune() then return end
  local stun_mult = 1

  if ability then
    if ability:GetAbilityName() == "ancient_2__leap" then stun_mult = 0.8 end
    if ability:GetAbilityName() == "ancient_3__roar" then stun_mult = 1.5 end
  end

  local stun_duration = CalcStatusResistance(self.ability:GetSpecialValueFor("stun_duration") * damage * stun_mult * 0.01, target)
  AddModifier(target, self.ability, "_modifier_stun", {duration = stun_duration}, false)

  if ability == nil then return end
  if ability:GetAbilityName() ~= "ancient_3__roar" then return end

  local cast_range = ability:GetSpecialValueFor("cast_range")
  local distance_percent = 1 - ((self.parent:GetOrigin() - target:GetOrigin()):Length2D() / cast_range)
  if distance_percent < 0.2 then distance_percent = 0.2 end
  if distance_percent > 1 then distance_percent = 1 end

  local knockback_duration = stun_duration * distance_percent * 0.25
  local knockback_distance = stun_duration * distance_percent * cast_range * 0.2

  AddModifier(target, self, "modifier_knockback", {
    center_x = self.parent:GetAbsOrigin().x + 1,
    center_y = self.parent:GetAbsOrigin().y + 1,
    center_z = self.parent:GetAbsOrigin().z,
    knockback_height = 0,
    duration = knockback_duration,
    knockback_duration = CalcStatus(knockback_duration, self.parent, target),
    knockback_distance = CalcStatus(knockback_distance, self.parent, target)
  }, true)
end

-- EFFECTS -----------------------------------------------------------

function ancient_1_modifier_passive:PlayEfxCrit(target, damage, sound)
	local particle_screen = "particles/econ/items/earthshaker/earthshaker_arcana/earthshaker_arcana_aftershock_screen.vpcf"
	local effect_screen = ParticleManager:CreateParticleForPlayer(particle_screen, PATTACH_WORLDORIGIN, nil, target:GetPlayerOwner())

  local particle_shake = "particles/osiris/poison_alt/osiris_poison_splash_shake.vpcf"
	local effect = ParticleManager:CreateParticle(particle_shake, PATTACH_ABSORIGIN, target)
	ParticleManager:SetParticleControl(effect, 0, target:GetOrigin())
	ParticleManager:SetParticleControl(effect, 1, Vector(damage * 2, 0, 0))

  if sound ~= nil then
    if IsServer() then target:EmitSound("Ancient.Stun.Crit") end
  end
end