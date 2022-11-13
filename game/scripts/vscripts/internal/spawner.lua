if Spawner == nil then
  DebugPrint( '[BAREBONES] creating spawner' )
  _G.Spawner = class({})
end

function Spawner:SpawnNeutrals()
  local time = GameRules:GetDOTATime(false, false)
  local current_mobs = 0

  while current_mobs < 12 do
    local free_spots = {}
    local free_spot_index = 1
    current_mobs = 0

    for i = 1, 20, 1 do
      local spot_blocked = self:IsSpotAlive(i)
      if not spot_blocked then spot_blocked = self:IsSpotCooldown(i) end
      if spot_blocked then
        current_mobs = current_mobs + 1
      else
        free_spots[free_spot_index] = i
        free_spot_index = free_spot_index + 1
      end
    end

    if current_mobs < 12 then
      self:CheckSpots(free_spots)
    end
  end
end

function Spawner:IsSpotAlive(spot)
  for category, units in pairs(SPAWNER_SPOTS[spot]["mob"]) do
    if category == "units" then
      for _,unit in pairs(units) do
        if IsValidEntity(unit) then
          if unit:IsAlive() then
            return true
          end
        end
      end
    end
  end

  return false
end

function Spawner:IsSpotCooldown(spot)
  local current_time = GameRules:GetDOTATime(false, false)
  local respawn_time = 45

  if SPAWNER_SPOTS[spot]["respawn"] == nil then
    SPAWNER_SPOTS[spot]["respawn"] = current_time
    return true
  end

  return (respawn_time > (current_time - SPAWNER_SPOTS[spot]["respawn"]))
end

function Spawner:CheckSpots(free_spots)
  self:CreateMob(free_spots[RandomInt(1, #free_spots)])
end

function Spawner:CreateMob(spot)
  local tier = self:RandomizeTier()
  local mob = self:RandomizeMob(tier)
  self:SpawnMobs(spot, tier, mob)
end

function Spawner:RandomizeTier()
  local time = GameRules:GetDOTATime(false, false)
  local start_time = 100
  if GetMapName() == "arena_turbo" then start_time = 900 end

  for i = 4, 2, -1 do
    local chance = ((time + start_time)/ i) * 0.1
    if chance > 75 then chance = 75 end
    if RandomFloat(1, 100) <= chance then
      return i
    end
  end

  return 1
end

function Spawner:RandomizeMob(tier)
  local rand_mobs = {}
  local index = 0
  for _,mob in pairs(SPAWNER_MOBS) do
    if mob["tier"] == tier then
      --print(mob["tier"], mob["units"], "pass")
      index = index + 1
      rand_mobs[index] = mob["units"]
    end
  end

  print(rand_mobs[RandomInt(1, index)], index, "index")

  return rand_mobs[RandomInt(1, index)]
end

function Spawner:SpawnMobs(spot, tier, mob)
  local spawned_units = {}
  for _,unit in pairs(mob) do
    local spawned_unit = CreateUnitByName(unit, SPAWNER_SPOTS[spot]["origin"], true, nil, nil, DOTA_TEAM_NEUTRALS)
    table.insert(spawned_units, spawned_unit)
    local ai = spawned_unit:FindModifierByName("_modifier__ai")
    if ai then ai.spot_origin = SPAWNER_SPOTS[spot]["origin"] end
  end

  SPAWNER_SPOTS[spot]["respawn"] = nil
  SPAWNER_SPOTS[spot]["mob"] = {
    ["tier"] = tier, ["units"] = spawned_units
  }
end

function Spawner:RandomizePlayerSpawn(unit)
  local further_loc = nil
  local further_distance = nil
 
  local enemies = FindUnitsInRadius(
    unit:GetTeamNumber(), unit:GetOrigin(), nil, FIND_UNITS_EVERYWHERE, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO,
    DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO,
    0, false
  )

  for _,loc in pairs(SPAWN_POS) do
    local closer = nil
    local distance = 0
    
    for _,enemy in pairs(enemies) do
      if (enemy:IsAlive() == false and enemy:IsReincarnating()) or enemy:IsAlive() then
        if closer == nil then
          closer = loc
          distance = (loc - enemy:GetAbsOrigin()):Length()
        end
        if (loc - enemy:GetAbsOrigin()):Length() < distance then
          closer = loc
          distance = (loc - enemy:GetAbsOrigin()):Length()
        end
      end
    end

    if further_loc == nil then
      further_loc = closer
      further_distance = distance
    else
      if distance > further_distance then
        further_loc = closer
        further_distance = distance
      end
    end
  end

  if further_loc == nil then
    further_loc = SPAWN_POS[RandomInt(1, 15)]
  end

  unit:SetOrigin(further_loc)
  FindClearSpaceForUnit(unit, further_loc, true)
end