if not icebreaker then
	icebreaker = {}
  icebreaker.values = {}
  icebreaker.random_values = {}
end

function icebreaker:TrySpell(target)
  local cast = false
  self.target = target

  if self.caster:IsCommandRestricted() then return cast end

  local abilities_actions = {
    [1] = self.TryCast_Zero,
    [2] = self.TryCast_Blink,
    [3] = self.TryCast_Wave,
    [4] = self.TryCast_Skin,
    [5] = self.TryCast_Shivas,
  }

  for i = 1, #abilities_actions, 1 do
    if cast == false then
      cast = abilities_actions[i](self)
    end
  end

  return cast
end

function icebreaker:TryCast_Zero()
  local ability = self.caster:FindAbilityByName("icebreaker_u__zero")
  if IsAbilityCastable(ability) == false then return false end

  local targets = 0

  local units = FindUnitsInRadius(
    self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, self.caster:GetCurrentVisionRange(),
    DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false
  )

  for _,unit in pairs(units) do
    if self.caster:CanEntityBeSeenByMyTeam(unit)
    and unit:IsHero() or unit:IsConsideredHero() then
      targets = targets + 1
    end
  end

  if targets == 0 then return false end
  
  local point = self.caster:GetOrigin() + RandomVector(ability:GetCastRange(self.caster:GetOrigin(), self.caster))
  self.caster:CastAbilityOnPosition(point, ability, self.caster:GetPlayerOwnerID())

  return true
end

function icebreaker:TryCast_Blink()
  local ability = self.caster:FindAbilityByName("icebreaker_5__blink")
  if IsAbilityCastable(ability) == false then return false end

  local target = nil

  local units = FindUnitsInRadius(
    self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, ability:GetCastRange(self.caster:GetOrigin(), self.caster),
    ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(),
    DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false
  )

  for _,unit in pairs(units) do
    if self.caster:CanEntityBeSeenByMyTeam(unit)
    and unit:HasModifier("icebreaker__modifier_frozen") then
      target = unit
      break
    end
  end

  local distance_diff = CalcDistanceBetweenEntityOBB(self.caster, self.target)
  if target == nil and ability:GetCurrentAbilityCharges() > 1 and distance_diff > 300 then target = self.target end

  if target == nil then return false end

  self.caster:CastAbilityOnTarget(target, ability, self.caster:GetPlayerOwnerID())

  return true
end

function icebreaker:TryCast_Wave()
  local ability = self.caster:FindAbilityByName("icebreaker_2__wave")
  if IsAbilityCastable(ability) == false then return false end

  if self.target:IsHero() == false and self.target:IsConsideredHero() == false then return false end

  local distance_diff = CalcDistanceBetweenEntityOBB(self.caster, self.target)
  local distance = ability:GetSpecialValueFor("distance") * 0.8
  if distance_diff > distance and self.caster:IsCommandRestricted() == false then
    self.caster:MoveToNPC(self.target)
    return true
  end

  self.caster:CastAbilityOnPosition(self.target:GetOrigin(), ability, self.caster:GetPlayerOwnerID())

  return true
end

function icebreaker:TryCast_Skin()
  local ability = self.caster:FindAbilityByName("icebreaker_3__skin")
  if IsAbilityCastable(ability) == false then return false end

  local target = nil

  local units = FindUnitsInRadius(
    self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, ability:GetCastRange(self.caster:GetOrigin(), self.caster),
    ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(),
    ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false
  )

  for _,unit in pairs(units) do
    if self.caster:CanEntityBeSeenByMyTeam(unit) and unit:GetNumAttackers() > 0 then
      target = unit
      break
    end
  end

  if target == nil then return false end

  self.caster:CastAbilityOnTarget(target, ability, self.caster:GetPlayerOwnerID())

  return true
end

function icebreaker:TryCast_Shivas()
  local ability = self.caster:FindAbilityByName("icebreaker_4__shivas")
  if IsAbilityCastable(ability) == false then return false end

  if self.target:IsHero() == false and self.target:IsConsideredHero() == false then return false end

  local distance_diff = CalcDistanceBetweenEntityOBB(self.caster, self.target)
  local distance = ability:GetSpecialValueFor("blast_radius") * 0.8
  if distance_diff > distance and self.caster:IsCommandRestricted() == false then
    self.caster:MoveToNPC(self.target)
    return true
  end

  self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())

  return true
end

function icebreaker:RandomizeValue(ability, value_name)
end

return icebreaker