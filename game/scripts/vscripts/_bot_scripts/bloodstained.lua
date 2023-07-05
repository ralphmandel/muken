if not bloodstained then
	bloodstained = {}
  bloodstained.values = {}
  bloodstained.random_values = {}
end

function bloodstained:TrySpell(target)
  local cast = false
  self.target = target

  if self.caster:IsCommandRestricted() then return cast end

  local abilities_actions = {
    [1] = self.TryCast_Rage,
    [2] = self.TryCast_Curse,
    [3] = self.TryCast_Tear,
    [4] = self.TryCast_Seal,
  }

  for i = 1, #abilities_actions, 1 do
    if cast == false then
      cast = abilities_actions[i](self)
    end
  end

  return cast
end

function bloodstained:TryCast_Rage()
  local ability = self.caster:FindAbilityByName("bloodstained_1__rage")
  if IsAbilityCastable(ability) == false then return false end

  local total_targets = 0
  local enemies = FindUnitsInRadius(
    self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, ability:GetAOERadius() - 50,
    ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(),
    ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false
  )

  for _,enemy in pairs(enemies) do
    if self.caster:CanEntityBeSeenByMyTeam(enemy) then
      total_targets = total_targets + 1
    end
  end

  if total_targets == 0 then return false end

  self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())

  return true
end

function bloodstained:TryCast_Curse()
  local ability = self.caster:FindAbilityByName("bloodstained_3__curse")
  if IsAbilityCastable(ability) == false then return false end

  self.caster:CastAbilityOnTarget(self.target, ability, self.caster:GetPlayerOwnerID())

  return true
end

function bloodstained:TryCast_Tear()
  local ability = self.caster:FindAbilityByName("bloodstained_4__tear")
  if IsAbilityCastable(ability) == false then return false end

  if ability:GetCurrentAbilityCharges() == 1 then
    if self.caster:GetHealthPercent() < 40 then return false end

    local total_targets = 0
    local enemies = FindUnitsInRadius(
      self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, ability:GetAOERadius(),
      ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(),
      ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false
    )
  
    for _,enemy in pairs(enemies) do
      if self.caster:CanEntityBeSeenByMyTeam(enemy) then
        total_targets = total_targets + 1
      end
    end

    if total_targets == 0 then return false end
  else
    local mod = self.caster:FindModifierByName("bloodstained_4_modifier_tear")
    if mod == nil then return false end
    if self.caster:GetHealthPercent() > 15 and mod:GetElapsedTime() < 20 then return false end
  end

  self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())

  return true
end

function bloodstained:TryCast_Seal()
  local ability = self.caster:FindAbilityByName("bloodstained_u__seal")
  if IsAbilityCastable(ability) == false then return false end

  if self.target:GetHealthPercent() >= 50 then return false end

  self.caster:CastAbilityOnPosition(self.target:GetOrigin(), ability, self.caster:GetPlayerOwnerID())

  return true
end

function bloodstained:RandomizeValue(ability, value_name)
end

return bloodstained