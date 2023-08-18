if not genuine then
	genuine = {}
  genuine.values = {}
  genuine.random_values = {}
end

function genuine:TrySpell(target, state)
  local cast = false
  self.target = target
  self.state = state

  if self.caster:IsCommandRestricted() then return cast end

  local travel = self.caster:FindAbilityByName("genuine_3__travel")
  if travel then
    if travel:IsTrained() then
      if travel:GetCurrentAbilityCharges() == 1 then return true end
    end
  end

  local abilities_actions = {
    [1] = self.TryCast_Nightfall,
    [2] = self.TryCast_Travel,
    [3] = self.TryCast_Morning,
    [4] = self.TryCast_Fallen,
    [5] = self.TryCast_Shooting
  }

  for i = 1, #abilities_actions, 1 do
    if cast == false or cast == nil then
      cast = abilities_actions[i](self)
    end
  end

  if cast == nil then return false end

  return cast
end

function genuine:TryCast_Nightfall()
  local ability = self.caster:FindAbilityByName("genuine_5__nightfall")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return false
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    if self.target:IsHero() == false and self.target:IsConsideredHero() == false then return false end
  
    local distance_diff = CalcDistanceBetweenEntityOBB(self.caster, self.target)
    local atk_range = self.caster:Script_GetAttackRange() + 100
    local cast_range = ability:GetCastRange(self.caster:GetOrigin(), nil) - 400
    if distance_diff < atk_range then return false end
    if distance_diff > cast_range then return false end
  
    self.caster:CastAbilityOnPosition(self.target:GetOrigin(), ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function genuine:TryCast_Travel()
  local ability = self.caster:FindAbilityByName("genuine_3__travel")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    self.caster:CastAbilityOnPosition(GetShrineTarget(self.caster):GetOrigin(), ability, self.caster:GetPlayerOwnerID())
    return true
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    local current_distance = 400
    local target = nil

    local attackers = GetAllAttackers(self.caster)

    if attackers then
      for _,attacker in pairs(attackers) do
        local dist_diff = CalcDistanceBetweenEntityOBB(self.caster, attacker)

        if dist_diff < current_distance and self.caster:CanEntityBeSeenByMyTeam(attacker) then
          target = attacker
          current_distance = dist_diff
        end
      end
    end
  
    if target == nil then return false end
    self.caster:FindModifierByName("_general_script").attack_target = target
  
    self.caster:CastAbilityOnPosition(target:GetOrigin(), ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function genuine:TryCast_Morning()
  local ability = self.caster:FindAbilityByName("genuine_u__morning")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return false
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then return false end
    if self.target:IsHero() == false and self.target:IsConsideredHero() == false then return false end
    
    local dist_diff = CalcDistanceBetweenEntityOBB(self.caster, self.target)
    if dist_diff > 1500 then return false end

    self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function genuine:TryCast_Fallen()
  local ability = self.caster:FindAbilityByName("genuine_2__fallen")
  if IsAbilityCastable(ability) == false then return false end

  local distance = ability:GetSpecialValueFor("distance") * 0.8

  if self.state == BOT_STATE_FLEE then
    local target = nil

    local units = FindUnitsInRadius(
      self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, distance,
      ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(),
      ability:GetAbilityTargetFlags(), FIND_CLOSEST, false
    )
  
    for _,unit in pairs(units) do
      if self.caster:CanEntityBeSeenByMyTeam(unit) then
        target = unit
        break
      end
    end

    if target == nil then return false end

    self.caster:CastAbilityOnPosition(target:GetOrigin(), ability, self.caster:GetPlayerOwnerID())
    return true
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    if self.target:IsStunned() then return false end
    if self.target:IsHero() == false and self.target:IsConsideredHero() == false then return false end
  
    local distance_diff = CalcDistanceBetweenEntityOBB(self.caster, self.target)
    if distance_diff > distance and self.caster:IsCommandRestricted() == false then
      self.caster:MoveToNPC(self.target)
      return true
    end
  
    self.caster:CastAbilityOnPosition(self.target:GetOrigin(), ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function genuine:TryCast_Shooting()
  local ability = self.caster:FindAbilityByName("genuine_1__shooting")
  if IsAbilityCastable(ability) == false then return false end

  if ability:GetAutoCastState() == false then ability:ToggleAutoCast() end
  
  return false
end

function genuine:RandomizeValue(ability, value_name)
end

return genuine