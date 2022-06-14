if (not _G.hero_stats_table) then
    _G.hero_stats_table = class({})
end

function hero_stats_table:Init()
    if (not IsServer()) then
        return
    end

    hero_stats_table.stats_primary = {
        "STR", "AGI", "INT", "CON"
    }

    hero_stats_table.stats_secondary = {
        "DEX", "DEF", "RES", "REC", "LCK", "MND"
    }

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

    local base_stats = hero:FindAbilityByName("base_stats")
    if (not base_stats) then return end

    for _,primary in pairs(hero_stats_table.stats_primary) do
        if event.stat == primary then
            base_stats.primary_points = base_stats.primary_points - 1
            base_stats.stat_base[event.stat] = base_stats.stat_base[event.stat] + 1
            base_stats.stat_levelup[event.stat] = base_stats.stat_levelup[event.stat] + 1
            base_stats:IncrementFraction(primary, 3)
            base_stats:CalculateStats(0, 0, primary)
        end
    end

    for _,secondary in pairs(hero_stats_table.stats_secondary) do
        if event.stat == secondary then
            base_stats.secondary_points = base_stats.secondary_points - 1
            base_stats.stat_base[event.stat] = base_stats.stat_base[event.stat] + 1
            base_stats.stat_levelup[event.stat] = base_stats.stat_levelup[event.stat] + 1
            base_stats:IncrementFraction(event.stat, 2)
            base_stats:CalculateStats(0, 0, event.stat)
        end
    end

    base_stats:UpdatePanoramaPoints()
end

function hero_stats_table:OnPlayerReconnect(keys)
    if (not IsServer()) then return end
    
    local player = EntIndexToHScript(keys.PlayerID)
    if (not player) then return end

    local hero = player:GetAssignedHero()
    if (not hero) then return end

    local base_stats = hero:FindAbilityByName("base_stats")
    if (not base_stats) then return end
    base_stats:UpdatePanoramaPoints()
end

hero_stats_table:Init()