if not lawbreaker then
	lawbreaker = {}
  lawbreaker.values = {}
  lawbreaker.random_values = {}
end

function lawbreaker:TrySpell(target, state)
  local cast = false
  self.target = target
  self.state = state

  if self.caster:IsCommandRestricted() then return cast end

  local abilities_actions = {
    [1] = self.TryCast_Blink,
    [2] = self.TryCast_Combo,
    [3] = self.TryCast_Form,
    [4] = self.TryCast_Grenade,
    [5] = self.TryCast_Rain
  }

  for i = 1, #abilities_actions, 1 do
    if cast == false then
      cast = abilities_actions[i](self)
    end
  end

  return cast
end

function lawbreaker:TryCast_Blink()
  local ability = self.caster:FindAbilityByName("lawbreaker_5__blink")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    self.caster:CastAbilityOnPosition(GetFountainLoc(self.caster), ability, self.caster:GetPlayerOwnerID())
    return true
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    local vDest = self.target:GetOrigin()
    local min_distance = self.caster:Script_GetAttackRange()
  
    local mod = self.caster:FindModifierByName("lawbreaker_2_modifier_combo")
    if mod then
      vDest = mod:CalcPosition(self.target) or vDest
      min_distance = 250
    end
  
    if (vDest - self.caster:GetOrigin()):Length2D() <= min_distance then return false end
  
    self.caster:CastAbilityOnPosition(vDest, ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function lawbreaker:TryCast_Combo()
  local ability = self.caster:FindAbilityByName("lawbreaker_2__combo")
  if self.caster:HasModifier("lawbreaker_2_modifier_combo") then return true end
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return false
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    local distance_diff = CalcDistanceBetweenEntityOBB(self.caster, self.target)
    local atk_range = self.caster:Script_GetAttackRange()
    if distance_diff > atk_range then return false end
  
    local angle = VectorToAngles(self.target:GetOrigin() - self.caster:GetOrigin())
    local angle_diff = AngleDiff(self.caster:GetAngles().y, angle.y)
    if angle_diff < -5 or angle_diff > 5 then return false end
  
    if self.random_values["combo_bullets"] == nil then self:RandomizeValue(ability, "combo_bullets") end
    if self.caster:FindModifierByName(ability:GetIntrinsicModifierName()):GetStackCount() < self.random_values["combo_bullets"] then return false end
  
    self:RandomizeValue(ability, "combo_bullets")
    self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function lawbreaker:TryCast_Form()
  local ability = self.caster:FindAbilityByName("lawbreaker_u__form")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return false
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    local total_targets = 0
    local enemies = FindUnitsInRadius(
      self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, 1500,
      DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL,
      DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false
    )
  
    for _,enemy in pairs(enemies) do
      if self.caster:CanEntityBeSeenByMyTeam(enemy)
      and enemy:IsHero() or enemy:IsConsideredHero() then
        total_targets = total_targets + 1
      end
    end
  
    if total_targets <= 1 then return false end
  
    self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function lawbreaker:TryCast_Grenade()
  local ability = self.caster:FindAbilityByName("lawbreaker_3__grenade")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return false
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    if self.target:IsHero() == false and self.target:IsConsideredHero() == false then return false end

    self.caster:CastAbilityOnPosition(self.target:GetOrigin(), ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function lawbreaker:TryCast_Rain()
  local ability = self.caster:FindAbilityByName("lawbreaker_4__rain")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    self.caster:CastAbilityOnPosition(self.caster:GetOrigin(), ability, self.caster:GetPlayerOwnerID())
    return true
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    if self.target:IsHero() == false and self.target:IsConsideredHero() == false then return false end

    self.caster:CastAbilityOnPosition(self.target:GetOrigin(), ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function lawbreaker:RandomizeValue(ability, value_name)
  if value_name == "combo_bullets" then
    self.random_values[value_name] = RandomInt(ability:GetSpecialValueFor("min_shots"), ability:GetSpecialValueFor("max_shots"))
  end
end

return lawbreaker