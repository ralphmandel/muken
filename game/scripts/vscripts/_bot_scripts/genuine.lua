if not genuine then
	genuine = {}
  genuine.values = {}
  genuine.random_values = {}
end

function genuine:TrySpell(caster, target)
  local cast = false
  self.caster = caster
  self.target = target
  self.script = caster:FindModifierByName("general_script")

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

  self.caster:CastAbilityOnPosition(self.target:GetOrigin(), ability, self.caster:GetPlayerOwnerID())

  return true
end

function genuine:TryCast_Morning()
  local ability = self.caster:FindAbilityByName("genuine_3__morning")
  if IsAbilityCastable(ability) == false then return false end
  if GameRules:State_Get() == DOTA_GAMERULES_STATE_PRE_GAME then return false end

  self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())
  self.script.interval = ability:GetCastPoint() + 0.5

  return true
end

function genuine:TryCast_Fallen()
  local ability = self.caster:FindAbilityByName("genuine_2__fallen")
  if IsAbilityCastable(ability) == false then return false end

  local distance = ability:GetSpecialValueFor("distance") * 0.75
  local distance_diff = CalcDistanceBetweenEntityOBB(self.caster, self.target)

  if distance_diff > distance then return false end

  self.caster:CastAbilityOnPosition(self.target:GetOrigin(), ability, self.caster:GetPlayerOwnerID())
  self.script.interval = ability:GetCastPoint() + 0.5

  return true
end

function genuine:TryCast_Star()
  local ability = self.caster:FindAbilityByName("genuine_u__star")
  if IsAbilityCastable(ability) == false then return false end

  self.caster:CastAbilityOnTarget(self.target, ability, self.caster:GetPlayerOwnerID())
  self.script.interval = ability:GetCastPoint() + 0.5

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