if not dasdingo then
	dasdingo = {}
  dasdingo.values = {}
  dasdingo.random_values = {}
end

function dasdingo:TrySpell(target, state)
  local cast = false
  self.target = target
  self.state = state

  local leech = self.caster:FindAbilityByName("dasdingo_3__leech")
  if IsAbilityCastable(leech) == true then
    if leech:IsChanneling() then return true end
  end

  if self.caster:IsCommandRestricted() then return cast end

  local abilities_actions = {
    [1] = self.TryCast_Tribal,
    [2] = self.TryCast_Curse,
    [3] = self.TryCast_Hex,
    [4] = self.TryCast_Field,
    [5] = self.TryCast_Leech,
    [6] = self.TryCast_tree
  }

  for i = 1, #abilities_actions, 1 do
    if cast == false or cast == nil then
      cast = abilities_actions[i](self)
    end
  end

  if cast == nil then return false end

  return cast
end

function dasdingo:TryCast_Tribal()
  local ability = self.caster:FindAbilityByName("dasdingo_4__tribal")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return false
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    if ability.unit ~= nil then
      if IsValidEntity(ability.unit) then
        local distance_diff = CalcDistanceBetweenEntityOBB(self.caster, ability.unit)
        if distance_diff < 1000 then return false end
      end
    end

    local targets = 0

    local units = FindUnitsInRadius(
      self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, self.caster:GetCurrentVisionRange(),
      DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
      DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_ANY_ORDER, false
    )
  
    for _,unit in pairs(units) do
      if self.caster:CanEntityBeSeenByMyTeam(unit)
      and unit:IsHero() or unit:IsConsideredHero() then
        targets = targets + 1
      end
    end
  
    if targets == 0 then return false end
    
    local point = self.caster:GetOrigin() + RandomVector(ability:GetCastRange(self.caster:GetOrigin(), nil))
    self.caster:CastAbilityOnPosition(point, ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function dasdingo:TryCast_Curse()
  local ability = self.caster:FindAbilityByName("dasdingo_u__curse")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return false
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    if self.target:IsStunned() then return false end
    if self.target:IsHero() == false and self.target:IsConsideredHero() == false then return false end
  
    self.caster:CastAbilityOnPosition(self.target:GetOrigin(), ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function dasdingo:TryCast_Hex()
  local ability = self.caster:FindAbilityByName("dasdingo_5__hex")
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

function dasdingo:TryCast_Field()
  local ability = self.caster:FindAbilityByName("dasdingo_1__field")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())
    return true
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    local target = nil

    local units = FindUnitsInRadius(
      self.caster:GetTeamNumber(), self.caster:GetOrigin(), nil, ability:GetAOERadius(),
      ability:GetAbilityTargetTeam(), ability:GetAbilityTargetType(),
      ability:GetAbilityTargetFlags(), FIND_ANY_ORDER, false
    )
  
    for _,unit in pairs(units) do
      if self.caster:CanEntityBeSeenByMyTeam(unit) and unit:GetNumAttackers() > 0 then
        target = unit
        break
      end
    end
  
    if target == nil then return false end
  
    self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function dasdingo:TryCast_Leech()
  local ability = self.caster:FindAbilityByName("dasdingo_3__leech")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return false
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    if self.target:IsStunned() then return false end
    if self.target:IsHero() == false and self.target:IsConsideredHero() == false then return false end
  
    self.caster:CastAbilityOnTarget(self.target, ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function dasdingo:TryCast_tree()
  local ability = self.caster:FindAbilityByName("dasdingo_2__tree")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_FLEE then
    return false
  end

  if self.state == BOT_STATE_AGGRESSIVE or self.state == BOT_STATE_AGGRESSIVE_FIND_TARGET then
    local target = nil

    if self.tree then
      if IsValidEntity(self.tree) then
        local dist_diff = CalcDistanceBetweenEntityOBB(self.caster, self.tree)
        
        if self.tree:IsStanding() and dist_diff <= ability:GetAOERadius()
        and self:HasBuffedTreeNear(self.tree:GetOrigin(), ability) == false then
          target = self.tree
        end
      end
    end
    
    if target == nil then
      local trees = GridNav:GetAllTreesAroundPoint(self.caster:GetOrigin(), ability:GetAOERadius(), false)
      local min_range = ability:GetAOERadius()
  
      if trees then
        for _, tree in pairs(trees) do
          if self:HasBuffedTreeNear(tree:GetOrigin(), ability) == false then
            local dist_diff = CalcDistanceBetweenEntityOBB(self.caster, tree)
            if min_range > dist_diff then
              min_range = dist_diff
              target = tree
            end
          end
        end
      end
    end

    if target == nil then return false end
    
    self.tree = target
    self.caster:CastAbilityOnPosition(target:GetOrigin(), ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function dasdingo:RandomizeValue(ability, value_name)
end

function dasdingo:HasBuffedTreeNear(loc, ability)
  local thinkers = Entities:FindAllByClassnameWithin("npc_dota_thinker", loc, ability:GetAOERadius())
  for _, mod_thinker in pairs(thinkers) do
    local modifier = mod_thinker:FindModifierByNameAndCaster("dasdingo_2_modifier_aura", ability:GetCaster())
    if modifier then return true end
  end

  return false
end

return dasdingo