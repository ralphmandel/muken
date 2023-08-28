if not ancient then
	ancient = {}
  ancient.values = {}
  ancient.random_values = {}
end

function ancient:TrySpell(target, state)
  local cast = false
  self.target = target
  self.state = state

  if self.caster:IsCommandRestricted() then return cast end

  local abilities_actions = {
    [1] = self.TryCast_Leap,
    [2] = self.TryCast_Roar,
    [3] = self.TryCast_Fissure,
    [4] = self.TryCast_Walk
  }

  for i = 1, #abilities_actions, 1 do
    if cast == false or cast == nil then
      cast = abilities_actions[i](self)
    end
  end

  if cast == nil then return false end

  return cast
end

function ancient:TryCast_Leap()
  local ability = self.caster:FindAbilityByName("ancient_2__leap")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return false
  end

  if self.state == BOT_STATE_AGGRESSIVE then  
    if self.caster:HasModifier("ancient_2_modifier_jump") then return true end
    if self.caster:HasModifier("ancient_2_modifier_leap") then return true end

    local max_charge = ability:GetMaxAbilityCharges(ability:GetLevel())
    if self.random_values["leap_charges"] == nil then self:RandomizeValue(1, max_charge, "leap_charges") end
    if ability:GetCurrentAbilityCharges() < self.random_values["leap_charges"] then return false end
  
    self.caster:CastAbilityOnPosition(self.target:GetOrigin(), ability, self.caster:GetPlayerOwnerID())

    if ability:GetCurrentAbilityCharges() == 0 then
      self:RandomizeValue(1, max_charge, "leap_charges")
    else
      self.random_values["leap_charges"] = 0
    end

    return true
  end
end

function ancient:TryCast_Roar()
  local ability = self.caster:FindAbilityByName("ancient_3__roar")
  if IsAbilityCastable(ability) == false then return false end

  local find_order = nil

  if self.state == BOT_STATE_FLEE then
    find_order = FIND_CLOSEST
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    find_order = FIND_ANY_ORDER
  end

  if find_order == nil then return false end

  local target = nil

  local units = FindUnitsInRadius(
    self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, ability:GetCastRange(self.caster:GetOrigin(), nil) - 100,
    ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(),
    ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false
  )

  for _,unit in pairs(units) do
    if self.caster:CanEntityBeSeenByMyTeam(unit) and unit:IsStunned() == false
    and unit:IsHero() or unit:IsConsideredHero() then
      target = unit
      break
    end
  end

  if target == nil then return false end

  self.caster:CastAbilityOnTarget(target, ability, self.caster:GetPlayerOwnerID())
  return true
end

function ancient:TryCast_Fissure()
  local ability = self.caster:FindAbilityByName("ancient_u__fissure")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return false
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    if self.target:IsHero() == false and self.target:IsConsideredHero() == false then return false end

    local distance_diff = CalcDistanceBetweenEntityOBB(self.caster, self.target)
    local cast_range = ability:GetCastRange(self.caster:GetOrigin(), nil) - 500
    if cast_range < 300 then cast_range = 300 end
    if distance_diff > cast_range and self.caster:IsCommandRestricted() == false then
      self.caster:MoveToNPC(self.target)
      return true
    end
  
    if self.random_values["final_percent"] == nil then
      self:RandomizeValue(ability:GetSpecialValueFor("min_cost"), 90, "final_percent")
    end

    if self.caster:GetManaPercent() < self.random_values["final_percent"] then return false end
  
    self.caster:CastAbilityOnPosition(self.target:GetOrigin(), ability, self.caster:GetPlayerOwnerID())
    self:RandomizeValue(ability:GetSpecialValueFor("min_cost"), 90, "final_percent")
    return true
  end
end

function ancient:TryCast_Walk()
  local ability = self.caster:FindAbilityByName("ancient_4__walk")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return false
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    if GetAllAttackers(self.caster) == nil then return false end

    self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function ancient:RandomizeValue(min_value, max_value, value_name)
  self.random_values[value_name] = RandomInt(min_value, max_value)
end

return ancient