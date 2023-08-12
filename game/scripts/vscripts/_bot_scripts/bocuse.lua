if not bocuse then
	bocuse = {}
  bocuse.values = {}
  bocuse.random_values = {}
end

function bocuse:TrySpell(target, state)
  local cast = false
  self.target = target
  self.state = state

  if self.caster:IsCommandRestricted() then return cast end
  if self.caster:HasModifier("bocuse_1_modifier_julienne") then return false end

  local abilities_actions = {
    [1] = self.TryCast_Mirepoix,
    [2] = self.TryCast_Julienne,
    [3] = self.TryCast_Flambee,
    [4] = self.TryCast_Roux,
    [5] = self.TryCast_Mise,
  }

  for i = 1, #abilities_actions, 1 do
    if cast == false or cast == nil then
      cast = abilities_actions[i](self)
    end
  end

  if cast == nil then return false end

  return cast
end

function bocuse:TryCast_Mirepoix()
  local ability = self.caster:FindAbilityByName("bocuse_4__mirepoix")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return false
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    if self.target:IsHero() == false and self.target:IsConsideredHero() == false then return false end
  
    local distance_diff = CalcDistanceBetweenEntityOBB(self.caster, self.target)
    if distance_diff > 1500 then return false end
  
    self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function bocuse:TryCast_Julienne()
  local ability = self.caster:FindAbilityByName("bocuse_1__julienne")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return false
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    self.caster:CastAbilityOnTarget(self.target, ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function bocuse:TryCast_Flambee()
  local ability = self.caster:FindAbilityByName("bocuse_2__flambee")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    self.caster:CastAbilityOnTarget(self.caster, ability, self.caster:GetPlayerOwnerID())
    return true
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    local target = self.target

    local units = FindUnitsInRadius(
      self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, ability:GetCastRange(self.caster:GetOrigin(), nil),
      ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(),
      ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false
    )
  
    for _,unit in pairs(units) do
      if self.caster:CanEntityBeSeenByMyTeam(unit)
      and unit:IsHero() or unit:IsConsideredHero() then
        target = unit
        break
      end
    end

    self.caster:CastAbilityOnTarget(target, ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function bocuse:TryCast_Roux()
  local ability = self.caster:FindAbilityByName("bocuse_5__roux")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    if self.caster:GetAbsOrigin().z == 0 then return false end

    self.caster:CastAbilityOnPosition(self.caster:GetAbsOrigin(), ability, self.caster:GetPlayerOwnerID())
    return true
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    if self.target:GetAbsOrigin().z == 0 then return false end
    if self.target:IsHero() == false and self.target:IsConsideredHero() == false then return false end

    self.caster:CastAbilityOnPosition(self.target:GetAbsOrigin(), ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function bocuse:TryCast_Mise()
  local ability = self.caster:FindAbilityByName("bocuse_u__mise")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return false
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    if self.target:IsHero() == false and self.target:IsConsideredHero() == false then return false end

    local distance_diff = CalcDistanceBetweenEntityOBB(self.caster, self.target)
    local atk_range = self.caster:Script_GetAttackRange()
    if distance_diff > atk_range then return false end
  
    local angle = VectorToAngles(self.target:GetOrigin() - self.caster:GetOrigin())
    local angle_diff = AngleDiff(self.caster:GetAngles().y, angle.y)
    if angle_diff < -75 or angle_diff > 75 then return false end
  
    self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function bocuse:RandomizeValue(ability, value_name)
end

return bocuse