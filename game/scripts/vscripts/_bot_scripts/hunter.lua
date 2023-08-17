if not hunter then
	hunter = {}
  hunter.values = {}
  hunter.random_values = {}
end

function hunter:TrySpell(target, state)
  local cast = false
  self.target = target
  self.state = state
  self.traps = 0

  if self.caster:IsCommandRestricted() then return cast end

  local abilities_actions = {
    [1] = self.TryCast_Radar,
    [2] = self.TryCast_Trap,
    [3] = self.TryCast_Shot,
    [4] = self.TryCast_Camouflage,
    [5] = self.TryCast_Aim
  }

  for i = 1, #abilities_actions, 1 do
    if cast == false or cast == nil then
      cast = abilities_actions[i](self)
    end
  end

  if cast == nil then return false end

  return cast
end

function hunter:TryCast_Radar()
  local ability = self.caster:FindAbilityByName("hunter_3__radar")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_AGGRESSIVE_SEEK_TARGET then
    self.caster:CastAbilityOnPosition(self.target, ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function hunter:TryCast_Trap()
  local ability = self.caster:FindAbilityByName("hunter_5__trap")
  if IsAbilityCastable(ability) == false then return false end

  local direction = self.caster:GetForwardVector():Normalized()
  local loc = self.caster:GetOrigin() + (direction * 150)

  local trees = GridNav:GetAllTreesAroundPoint(loc, ability:GetAOERadius(), false)
  local units = FindUnitsInRadius(
    self.caster:GetTeamNumber(), loc, nil, ability:GetAOERadius(),
    DOTA_UNIT_TARGET_TEAM_BOTH, DOTA_UNIT_TARGET_ALL,
    DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE, 0, false
  )

  if trees then for _,tree in pairs(trees) do return false end end
  for _,unit in pairs(units) do return false end
  if (loc - Vector(0, 0, 0)):Length2D() > 5000 then return false end

  if self.state == BOT_STATE_FLEE then
    self.caster:CastAbilityOnPosition(loc, ability, self.caster:GetPlayerOwnerID())
    return true
  end

  if self.state == BOT_STATE_AGGRESSIVE then
    -- if self.traps == 0 then self.traps = ability:GetMaxAbilityCharges(ability:GetLevel()) end

    -- if ability:GetCurrentAbilityCharges() < self.traps then return false end

    -- self.traps = self.traps - 1

    self.caster:CastAbilityOnPosition(loc, ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function hunter:TryCast_Shot()
  local ability = self.caster:FindAbilityByName("hunter_1__shot")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_AGGRESSIVE then
    local target = nil
    local percent = 90

    for _, hero in pairs(HeroList:GetAllHeroes()) do
      if hero:IsAlive() and hero:GetTeamNumber() ~= self.caster:GetTeamNumber()
      and self.caster:CanEntityBeSeenByMyTeam(hero) then
        if hero:GetHealthPercent() < percent then
          percent = hero:GetHealthPercent()
          target = hero
        end
      end
    end

    if target == nil then return false end

    self.caster:CastAbilityOnTarget(target, ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function hunter:TryCast_Camouflage()
  local ability = self.caster:FindAbilityByName("hunter_u__camouflage")
  if ability == nil then return false end
  if ability:IsTrained() == false then return false end

  if self.caster:HasModifier("hunter_2_modifier_aim") then return false end

  if self.state == BOT_STATE_AGGRESSIVE then
    if self.caster:PassivesDisabled() then return false end
    if self.caster:IsCommandRestricted() then return false end
    if self.caster:HasModifier("hunter_u_modifier_camouflage") then
      self.tree = nil
      return false
    end

    local range = self.caster:Script_GetAttackRange() + ability:GetSpecialValueFor("atk_range")
    local direction = (self.caster:GetOrigin() - self.target:GetOrigin()):Normalized()
    local point = self.target:GetAbsOrigin() + direction * 300
    local trees = GridNav:GetAllTreesAroundPoint(point, range - 500, false)
    local target_tree = nil
    local distance = 0
    local dist_diff = 0

    if self.tree then
      if IsValidEntity(self.tree) then
        if self.tree:IsStanding() then
          dist_diff = (self.target:GetAbsOrigin() - self.tree:GetAbsOrigin()):Length2D()
          if dist_diff <= range and self:HasNearbyEnemy(self.tree:GetAbsOrigin()) == false then
            target_tree = self.tree
          end          
        end
      end
    end

    if trees and target_tree == nil then
      for _, tree in pairs(trees) do
        dist_diff = (self.target:GetAbsOrigin() - tree:GetAbsOrigin()):Length2D()
        
        if self:HasNearbyEnemy(tree:GetAbsOrigin()) == false and dist_diff > distance then
          distance = dist_diff
          target_tree = tree
        end
      end
    end

    if target_tree == nil then return false end

    self.tree = target_tree
    self.caster:MoveToPosition(target_tree:GetOrigin())
    return true
  end
end

function hunter:TryCast_Aim()
  local ability = self.caster:FindAbilityByName("hunter_2__aim")
  if IsAbilityCastable(ability) == false then return false end

  if self.state == BOT_STATE_AGGRESSIVE then
    local dist_diff = CalcDistanceBetweenEntityOBB(self.caster, self.target)
    if dist_diff > self.caster:Script_GetAttackRange() - 300 then return false end

    self.caster:CastAbilityNoTarget(ability, self.caster:GetPlayerOwnerID())
    return true
  end
end

function hunter:HasNearbyEnemy(loc)
  for _, hero in pairs(HeroList:GetAllHeroes()) do
    if hero:IsAlive() and hero:GetTeamNumber() ~= self.caster:GetTeamNumber() then
      local dist_diff = (hero:GetAbsOrigin() - loc):Length2D()
      if dist_diff > 400 then return false end
      return true
    end
  end
end

return hunter