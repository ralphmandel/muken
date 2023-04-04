if (not _G.hero_stats_table) then
  _G.hero_stats_table = class({})
end

function hero_stats_table:Init()
  if (not IsServer()) then return end

  hero_stats_table.stats_primary = {"STR", "AGI", "INT", "CON"}
  hero_stats_table.stats_secondary = {"DEX", "DEF", "RES", "REC", "LCK", "MND"}

  if hero_stats_table.initializated == nil then
    hero_stats_table.initializated = true
    hero_stats_table:InitPanaromaEvents()
  end

  ListenToGameEvent("player_reconnected", Dynamic_Wrap(hero_stats_table, "OnPlayerReconnect"), hero_stats_table)
end

function hero_stats_table:InitPanaromaEvents()
  CustomGameEventManager:RegisterListener("leveling_stat", Dynamic_Wrap(hero_stats_table, 'OnLevelUpStat'))
end

function hero_stats_table:OnLevelUpStat(event)
  if (not event or not event.PlayerID) then return end

  local player = PlayerResource:GetPlayer(event.PlayerID)
  if (not player) then return end

  local hero = player:GetAssignedHero()
  if (not hero) then return end

  if BaseStats(hero) == nil then return end

  for _,primary in pairs(hero_stats_table.stats_primary) do
    if event.stat == primary then
      BaseStats(hero).total_points = BaseStats(hero).total_points - 1
      BaseStats(hero).stat_base[event.stat] = BaseStats(hero).stat_base[event.stat] + 1
      BaseStats(hero):IncrementFraction("plus_up", primary, 3)
      BaseStats(hero):CalculateStats(0, 0, primary)
    end
  end

  for _,secondary in pairs(hero_stats_table.stats_secondary) do
    if event.stat == secondary then
      BaseStats(hero).total_points = BaseStats(hero).total_points - 1
      BaseStats(hero).stat_base[event.stat] = BaseStats(hero).stat_base[event.stat] + 1
      BaseStats(hero):IncrementFraction("plus_up", event.stat, 2)
      BaseStats(hero):CalculateStats(0, 0, event.stat)
    end
  end

  BaseStats(hero):UpdatePanoramaPoints(event.stat)
end

function hero_stats_table:OnPlayerReconnect(keys)
  if (not IsServer()) then return end
  
  local player = EntIndexToHScript(keys.PlayerID)
  if (not player) then return end

  local hero = player:GetAssignedHero()
  if (not hero) then return end

  if BaseStats(hero) == nil then return end

  for _,primary in pairs(hero_stats_table.stats_primary) do
    BaseStats(hero):UpdatePanoramaStat(primary)
  end

  for _,secondary in pairs(hero_stats_table.stats_secondary) do
    BaseStats(hero):UpdatePanoramaStat(secondary)
  end
  
  BaseStats(hero):UpdatePanoramaPoints("nil")
end

hero_stats_table:Init()