if not baldur then
	baldur = {}
  baldur.values = {}
  baldur.random_values = {}
end

function baldur:TrySpell(target, state)
  local cast = false
  self.target = target
  self.state = state
  self.time = nil

  if self.caster:IsCommandRestricted() then return cast end

  local abilities_actions = {
    [1] = self.TryCast_Dash,
    [2] = self.TryCast_Fire,
    [3] = self.TryCast_Barrier,
    [4] = self.TryCast_Endurance
  }

  for i = 1, #abilities_actions, 1 do
    if cast == false or cast == nil then
      cast = abilities_actions[i](self)
    end
  end

  if cast == nil then return false end

  return cast
end

function baldur:TryCast_Dash()
  local ability = self.caster:FindAbilityByName("baldur_2__dash")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return false
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    if ability:GetCurrentAbilityCharges() == BALDUR_CHARGING then
      local target = nil
      local modifier = self.caster:FindModifierByName("baldur_2_modifier_charge")
      local distance_diff = CalcDistanceBetweenEntityOBB(self.caster, self.target)

      if distance_diff < ability:GetSpecialValueFor("cast_range") then
        if modifier then
          if modifier.time < 1 or distance_diff > ability:GetSpecialValueFor("cast_range") - 75 then
            target = self.target
          end
        end
      else
        local enemies = FindUnitsInRadius(
          self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, ability:GetSpecialValueFor("cast_range"),
          ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(),
          ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false
        )
      
        for _,enemy in pairs(enemies) do
          if target == nil and self.caster:CanEntityBeSeenByMyTeam(enemy)
          and enemy:IsHero() or enemy:IsConsideredHero() then
            target = enemy
          end
        end
      end
  
      if target == nil then return true end

      self.caster:CastAbilityOnTarget(target, ability, self.caster:GetPlayerOwnerID())
      return true
    else
      local distance_diff = CalcDistanceBetweenEntityOBB(self.caster, self.target)
      if distance_diff > ability:GetSpecialValueFor("cast_range") - 150 then return false end

      self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())
      return true
    end
  end
end

function baldur:TryCast_Fire()
  local ability = self.caster:FindAbilityByName("baldur_5__fire")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return false
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    local target = nil
    local dist_diff = 0
    local min_range = self.caster:Script_GetAttackRange() - 10
    local max_range = ability:GetCastRange(self.caster:GetOrigin(), nil)

    if self.caster:GetNumAttackers() > 0 then
      for _, attacker in pairs(HeroList:GetAllHeroes()) do
				for i = 0, self.caster:GetNumAttackers() - 1 do
					if attacker:GetPlayerID() == self.caster:GetAttacker(i) then
            dist_diff = CalcDistanceBetweenEntityOBB(self.caster, attacker)
    
            if target == nil and dist_diff > min_range and dist_diff < max_range
            and self.caster:CanEntityBeSeenByMyTeam(attacker) then
              target = attacker
            end
					end
				end
			end
    end

    dist_diff = CalcDistanceBetweenEntityOBB(self.caster, self.target)
    if target == nil and dist_diff > min_range and dist_diff < max_range then target = self.target end
    if target:IsHero() == false and target:IsConsideredHero() == false then return false end

    self.caster:CastAbilityOnTarget(target, ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function baldur:TryCast_Barrier()
  local ability = self.caster:FindAbilityByName("baldur_3__barrier")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())
    return true
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    local modifier = self.caster:FindModifierByName("baldur_3_modifier_passive")

    if modifier and self.time then
      if modifier:GetStackCount() < 15 and GameRules:GetGameTime() - self.time < 60 then
        return false
      end
    end
  
    self.time = GameRules:GetGameTime()

    self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function baldur:TryCast_Endurance()
  local ability = self.caster:FindAbilityByName("baldur_u__endurance")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())
    return true
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    if self.caster:GetNumAttackers() == 0 then return false end
    if self.caster:GetHealthPercent() > 50 then return false end
  
    self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

return baldur