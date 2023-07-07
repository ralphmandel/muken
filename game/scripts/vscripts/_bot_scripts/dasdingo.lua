if not dasdingo then
	dasdingo = {}
  dasdingo.values = {}
  dasdingo.random_values = {}
end

function dasdingo:TrySpell(target)
  local cast = false
  self.target = target

  local leech = self.caster:FindAbilityByName("dasdingo_3__leech")
  if IsAbilityCastable(leech) == true then
    if leech:IsChanneling() then return true end
  end

  if self.caster:IsCommandRestricted() then return cast end

  local abilities_actions = {
    [1] = self.TryCast_Tribal,
    [2] = self.TryCast_Curse,
    [3] = self.TryCast_Field,
    [4] = self.TryCast_Leech
  }

  for i = 1, #abilities_actions, 1 do
    if cast == false then
      cast = abilities_actions[i](self)
    end
  end

  return cast
end

function dasdingo:TryCast_Tribal()
  local ability = self.caster:FindAbilityByName("dasdingo_4__tribal")
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

function dasdingo:TryCast_Curse()
  local ability = self.caster:FindAbilityByName("dasdingo_u__curse")
  if IsAbilityCastable(ability) == false then return false end
  
  if self.target:IsStunned() then return false end
  if self.target:IsHero() == false and self.target:IsConsideredHero() == false then return false end

  self.caster:CastAbilityOnPosition(self.target:GetOrigin(), ability, self.caster:GetPlayerOwnerID())

  return true
end

function dasdingo:TryCast_Field()
  local ability = self.caster:FindAbilityByName("dasdingo_1__field")
  if IsAbilityCastable(ability) == false then return false end

  local target = self.caster

  local units = FindUnitsInRadius(
    self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, self.caster:GetCurrentVisionRange(),
    DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
    DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false
  )

  for _,unit in pairs(units) do
    if self.caster:CanEntityBeSeenByMyTeam(unit)
    and (unit:IsHero() or unit:IsConsideredHero())
    and target:GetHealthPercent() > unit:GetHealthPercent() then
      target = unit
    end
  end
  
  local point = target:GetOrigin() + RandomVector(RandomInt(0, 150))
  self.caster:CastAbilityOnPosition(point, ability, self.caster:GetPlayerOwnerID())

  return true
end

function dasdingo:TryCast_Leech()
  local ability = self.caster:FindAbilityByName("dasdingo_3__leech")
  if IsAbilityCastable(ability) == false then return false end

  if self.target:IsStunned() then return false end
  if self.target:IsHero() == false and self.target:IsConsideredHero() == false then return false end

  self.caster:CastAbilityOnTarget(self.target, ability, self.caster:GetPlayerOwnerID())

  return true
end

function dasdingo:RandomizeValue(ability, value_name)
end

return dasdingo