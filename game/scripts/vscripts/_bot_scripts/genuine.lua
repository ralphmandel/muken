if not genuine then
	genuine = {}
  genuine.values = {}
  genuine.random_values = {}
end

function genuine:TrySpell(target)
  local cast = false
  self.target = target

  if self.caster:IsCommandRestricted() then return cast end

  local abilities_actions = {
    [1] = self.TryCast_Awakening,
    [2] = self.TryCast_Morning,
    [3] = self.TryCast_Fallen,
    [4] = self.TryCast_Star,
    [5] = self.TryCast_Shooting
  }

  for i = 1, #abilities_actions, 1 do
    if cast == false then
      cast = abilities_actions[i](self)
    end
  end

  return cast
end

function genuine:TryCast_Awakening()
  local ability = self.caster:FindAbilityByName("genuine_4__awakening")
  if IsAbilityCastable(ability) == false then return false end

  if ability:IsChanneling() then return true end
  if self.target:IsHero() == false and self.target:IsConsideredHero() == false then return false end

  local distance_diff = CalcDistanceBetweenEntityOBB(self.caster, self.target)
  local atk_range = self.caster:Script_GetAttackRange() + 50
  local cast_range = ability:GetCastRange(self.caster:GetOrigin(), self.caster) - 400
  if distance_diff < atk_range then return false end
  if distance_diff > cast_range then return false end

  self.caster:CastAbilityOnPosition(self.target:GetOrigin(), ability, self.caster:GetPlayerOwnerID())

  return true
end

function genuine:TryCast_Morning()
  local ability = self.caster:FindAbilityByName("genuine_3__morning")
  if IsAbilityCastable(ability) == false then return false end

  if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then return false end
  if self.target:IsHero() == false and self.target:IsConsideredHero() == false then return false end

  self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())

  return true
end

function genuine:TryCast_Fallen()
  local ability = self.caster:FindAbilityByName("genuine_2__fallen")
  if IsAbilityCastable(ability) == false then return false end

  if self.target:IsStunned() then return false end
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

function genuine:TryCast_Star()
  local ability = self.caster:FindAbilityByName("genuine_u__star")
  if IsAbilityCastable(ability) == false then return false end

  if self.caster:GetManaPercent() > 60 then return false end
  if self.target:IsHero() == false and self.target:IsConsideredHero() == false then return false end

  self.caster:CastAbilityOnTarget(self.target, ability, self.caster:GetPlayerOwnerID())

  return true
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