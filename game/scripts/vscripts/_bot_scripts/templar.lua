if not templar then
	templar = {}
  templar.values = {}
  templar.random_values = {}
end

function templar:TrySpell(target, state)
  local cast = false
  self.target = target
  self.state = state

  if self.caster:IsCommandRestricted() then return cast end

  local abilities_actions = {
    [1] = self.TryCast_Praise,
    [2] = self.TryCast_Barrier,
    [3] = self.TryCast_Hammer,
    [4] = self.TryCast_Circle,
    [5] = self.TryCast_Reborn,
  }

  for i = 1, #abilities_actions, 1 do
    if cast == false or cast == nil then
      cast = abilities_actions[i](self)
    end
  end

  if cast == nil then return false end

  return cast
end

function templar:TryCast_Praise()
  local ability = self.caster:FindAbilityByName("templar_u__praise")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE or self.state == BOT_STATE_AGGRESSIVE then
    local total_percent = 100
    for _, hero in pairs(HeroList:GetAllHeroes()) do
      if hero:IsAlive() and hero:GetTeamNumber() == self.caster:GetTeamNumber() then
        total_percent = total_percent - (100 - hero:GetHealthPercent())
      end
    end

    if total_percent > 20 then return false end

    self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function templar:TryCast_Barrier()
  local ability = self.caster:FindAbilityByName("templar_2__barrier")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    self.caster:CastAbilityOnTarget(self.caster, ability, self.caster:GetPlayerOwnerID())
    return true
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    local target = nil
    local current_percent = 100
    local num_attackers = 0

    local units = FindUnitsInRadius(
      self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, ability:GetCastRange(self.caster:GetOrigin(), nil),
      ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(),
      ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false
    )
  
    for _,unit in pairs(units) do
      local unit_num = 0
      if GetAllAttackers(unit) then unit_num = #GetAllAttackers(unit) end

      if self.caster:CanEntityBeSeenByMyTeam(unit) and unit_num >= num_attackers then
        if unit_num == num_attackers then
          if unit:GetHealthPercent() < current_percent then
            target = unit
            current_percent = unit:GetHealthPercent()
          end
        else
          target = unit
          num_attackers = unit_num
          current_percent = unit:GetHealthPercent()
        end
      end
    end
  
    if target == nil then return false end
  
    self.caster:CastAbilityOnTarget(target, ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function templar:TryCast_Hammer()
  local ability = self.caster:FindAbilityByName("templar_4__hammer")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    local target = nil
    local units = FindUnitsInRadius(
      self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, ability:GetCastRange(self.caster:GetOrigin(), nil),
      ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(),
      ability:GetAbilityTargetFlags(), FIND_CLOSEST, false
    )
  
    for _,unit in pairs(units) do
      if self.caster:CanEntityBeSeenByMyTeam(unit)
      and unit:IsHero() or unit:IsConsideredHero() then
        target = unit
        break
      end
    end

    if target == nil then return false end

    self.caster:CastAbilityOnTarget(target, ability, self.caster:GetPlayerOwnerID())
    return true
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    if self.target:IsStunned() then return false end
    if self.target:IsHero() == false and self.target:IsConsideredHero() == false then return false end

    self.caster:CastAbilityOnTarget(self.target, ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function templar:TryCast_Circle()
  local ability = self.caster:FindAbilityByName("templar_3__circle")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return false
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    local target = nil
    local number = 1
    local distance = ability:GetCastRange(self.caster:GetOrigin(), nil)

    for _, main_hero in pairs(HeroList:GetAllHeroes()) do
      local current_number = 0
      local has_enemy = false

      if CalcDistanceBetweenEntityOBB(self.caster, main_hero) < distance
      and main_hero:IsAlive() and self.caster ~= main_hero then
        for _, sub_hero in pairs(HeroList:GetAllHeroes()) do
          if sub_hero:IsAlive() and CalcDistanceBetweenEntityOBB(main_hero, sub_hero) < ability:GetAOERadius() then
            if self.caster:GetTeamNumber() ~= sub_hero:GetTeamNumber() then has_enemy = true end
            current_number = current_number + 1
          end
        end
      end

      if has_enemy == true and current_number > number then
        number = current_number
        target = main_hero
      end
    end

    if target == nil then return false end

    self.caster:CastAbilityOnPosition(target:GetOrigin(), ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function templar:TryCast_Reborn()
  local ability = self.caster:FindAbilityByName("templar_5__reborn")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return false
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    local target = nil
    local distance = 9999

    for _, hero in pairs(HeroList:GetAllHeroes()) do
      local dist_diff = CalcDistanceBetweenEntityOBB(self.caster, hero)
      
      if hero:GetTeamNumber() == self.caster:GetTeamNumber()
      and dist_diff < distance and hero ~= self.caster then
        if hero:IsAlive() == false and hero:IsReincarnating() == false 
        and hero:GetTimeUntilRespawn() > ability:GetCastPoint() then
          distance = dist_diff
          target = hero
        end
      end
    end
    
    if target == nil then return false end

    self.caster:CastAbilityOnPosition(target:GetOrigin(), ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function templar:RandomizeValue(ability, value_name)
end

return templar