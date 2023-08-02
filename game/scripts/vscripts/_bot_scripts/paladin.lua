if not paladin then
	paladin = {}
  paladin.values = {}
  paladin.random_values = {}
end

function paladin:TrySpell(target, state)
  local cast = false
  self.target = target
  self.state = state

  if self.caster:IsCommandRestricted() then return cast end

  local abilities_actions = {
    [1] = self.TryCast_Link,
    [2] = self.TryCast_Shield,
    [3] = self.TryCast_Hammer,
    [4] = self.TryCast_Magnus,
    [5] = self.TryCast_Smite,
  }

  for i = 1, #abilities_actions, 1 do
    if cast == false or cast == nil then
      cast = abilities_actions[i](self)
    end
  end

  if cast == nil then return false end

  return cast
end

function paladin:TryCast_Link()
  local ability = self.caster:FindAbilityByName("paladin_1__link")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return false
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    local target = nil

    local units = FindUnitsInRadius(
      self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, ability:GetCastRange(self.caster:GetOrigin(), self.caster),
      ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(),
      ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false
    )
  
    for _,unit in pairs(units) do
      if self.caster:CanEntityBeSeenByMyTeam(unit) and unit:GetNumAttackers() > 0 and unit ~= self.caster then
        target = unit
        break
      end
    end
  
    if target == nil then return false end
  
    self.caster:CastAbilityOnTarget(target, ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function paladin:TryCast_Shield()
  local ability = self.caster:FindAbilityByName("paladin_2__shield")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())
    return true
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    if self.caster:GetNumAttackers() == 0 then return false end
  
    self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function paladin:TryCast_Hammer()
  local ability = self.caster:FindAbilityByName("paladin_3__hammer")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    self.caster:CastAbilityOnTarget(self.caster, ability, self.caster:GetPlayerOwnerID())
    return true
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    local target = self.target
    local hp_cap = 99999

    local units = FindUnitsInRadius(
      self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, ability:GetCastRange(self.caster:GetOrigin(), self.caster),
      ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(),
      ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false
    )
  
    for _,unit in pairs(units) do
      if self.caster:CanEntityBeSeenByMyTeam(unit)
      and unit:IsHero() or unit:IsConsideredHero() then
        if hp_cap > unit:GetHealth() then
          hp_cap = unit:GetHealth()
          target = unit
        end
      end
    end

    self.caster:CastAbilityOnTarget(target, ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function paladin:TryCast_Magnus()
  local ability = self.caster:FindAbilityByName("paladin_4__magnus")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return false
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    local total_targets = 0
    local enemies = FindUnitsInRadius(
      self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, ability:GetAOERadius() - 100,
      ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(),
      ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false
    )
  
    for _,enemy in pairs(enemies) do
      if self.caster:CanEntityBeSeenByMyTeam(enemy)
      and enemy:IsHero() or enemy:IsConsideredHero() then
        total_targets = total_targets + 1
      end
    end
  
    if total_targets == 0 then return false end
  
    self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function paladin:TryCast_Smite()
  local ability = self.caster:FindAbilityByName("paladin_5__smite")
  if IsAbilityCastable(ability) == false then return false end

  if ability:GetAutoCastState() == false then ability:ToggleAutoCast() end
  
  return false
end

function paladin:RandomizeValue(ability, value_name)
  if value_name == "precision_charges" then
    self.random_values[value_name] = RandomInt(1, ability:GetMaxAbilityCharges(ability:GetLevel()))
  end
end

return paladin