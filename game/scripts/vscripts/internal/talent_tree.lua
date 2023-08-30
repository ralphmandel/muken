if (not _G.TalentTree) then
  _G.TalentTree = class({})
end

function TalentTree:Init()
  if (not IsServer()) then return end

  if TalentTree.initializated == nil then
    TalentTree.initializated = true
    TalentTree:InitPanaromaEvents()
  end
end

function TalentTree:InitPanaromaEvents()
  CustomGameEventManager:RegisterListener("talent_tree_get_talents", Dynamic_Wrap(TalentTree, 'OnTalentTreeTalentsRequest'))
  CustomGameEventManager:RegisterListener("talent_tree_level_up_talent", Dynamic_Wrap(TalentTree, 'OnTalentTreeLevelUpRequest'))
  CustomGameEventManager:RegisterListener("talent_tree_get_state", Dynamic_Wrap(TalentTree, 'OnTalentTreeStateRequest'))
  CustomGameEventManager:RegisterListener("talent_tree_reset_talents", Dynamic_Wrap(TalentTree, 'OnTalentTreeResetRequest'))
  ListenToGameEvent("player_reconnected", Dynamic_Wrap(TalentTree, "OnPlayerReconnect"), TalentTree)
  
  CustomGameEventManager:RegisterListener("role_bar_update", Dynamic_Wrap(TalentTree, 'OnRoleBarRequest'))
  CustomGameEventManager:RegisterListener("scoreboard_update", Dynamic_Wrap(TalentTree, 'OnScoreRequest'))
  CustomGameEventManager:RegisterListener("portrait_unit_update", Dynamic_Wrap(TalentTree, 'OnPortraitUpdate'))
end

function TalentTree:OnRoleBarRequest(event)
  if (not event or not event.PlayerID) then return end
  
  local player = PlayerResource:GetPlayer(event.PlayerID)
  if (not player) then return end

  local heroes_stats_data = LoadKeyValues("scripts/kv/heroes_roles_level.kv")
  for hero, data in pairs(heroes_stats_data) do
    if hero == GetHeroName("npc_dota_hero_" .. event.id_name) then
      CustomGameEventManager:Send_ServerToPlayer(player, "role_bar_state_from_server", data)
    end
  end
end

function TalentTree:OnScoreRequest(event)
  if (not event or not event.PlayerID) then return end
  
  local player = PlayerResource:GetPlayer(event.PlayerID)
  if (not player) then return end

  local score_table = {
    [DOTA_TEAM_CUSTOM_1] = TEAMS[1][2],
    [DOTA_TEAM_CUSTOM_2] = TEAMS[2][2],
    [DOTA_TEAM_CUSTOM_3] = TEAMS[3][2],
    [DOTA_TEAM_CUSTOM_4] = TEAMS[4][2]
  }

  CustomGameEventManager:Send_ServerToPlayer(player, "score_state_from_server", score_table)
end

function TalentTree:OnPortraitUpdate(event)
  if (not IsServer()) then return end
  if (not event or not event.PlayerID) then return end
  local player = PlayerResource:GetPlayer(event.PlayerID)
  if (not player) then return end
  local hero = player:GetAssignedHero()
  if (not hero) then return end
  local entity = EntIndexToHScript(event.entity)
  if entity == nil then return end
  if IsValidEntity(entity) == false then return end
  if BaseStats(entity) == nil then return end
  if hero:CanEntityBeSeenByMyTeam(entity) == false then return end

  local info = {
    unit_name = entity:GetUnitName(),

    physical_damage = BaseStats(entity):GetTotalPhysicalDamagePercent(),
    attack_speed = entity:GetDisplayAttackSpeed(),
    armor = entity:GetPhysicalArmorValue(false),
    evasion = BaseStats(entity):GetDodgePercent(),
    crit_chance = BaseStats(entity):GetCriticalChance(),

    bonus_damage = BaseStats(entity):GetBonusAtkDamage(),
    movespeed = entity:GetIdealSpeed(),
    block = BaseStats(entity):GetBlockAtkDamage(),
    hp_regen = entity:GetHealthRegen(),
    crit_damage = 100 + BaseStats(entity):GetTotalCriticalDamage(),

    magical_damage = BaseStats(entity):GetTotalMagicalDamagePercent(),
    current_vision = entity:GetCurrentVisionRange(),
    magical_resist = entity:Script_GetMagicalArmorValue(false, BaseStats(entity)) * 100,
    mp_regen = entity:GetManaRegen(),
    debuff_amp = BaseStats(entity):GetTotalDebuffAmpPercent(),

    heal_power = BaseStats(entity):GetTotalHealPowerPercent(),
    heal_amp = 100 + BaseStats(entity):GetHealAmp(),
    status_resist = BaseStats(entity):GetStatusResistPercent(),
    cd_reduction = entity:GetCooldownReduction() * 100,
    buff_amp = BaseStats(entity):GetTotalBuffAmpPercent()
  }

  CustomGameEventManager:Send_ServerToPlayer(player, "info_state_from_server", info)
end

function TalentTree:OnTalentTreeTalentsRequest(event)
  if (not event or not event.PlayerID) then return end
  
  local player = PlayerResource:GetPlayer(event.PlayerID)
  if (not player) then return end

  local hero = player:GetAssignedHero()
  if (not hero) then return end

  if BaseHero(hero) == nil then return end

  BaseHero(hero):UpdatePanoramaPanels()
end

function TalentTree:OnTalentTreeLevelUpRequest(event)
  if (not IsServer()) then return end
  if (event == nil or not event.PlayerID) then return end

  local player = PlayerResource:GetPlayer(event.PlayerID)
  if (not player) then return end

  local hero = player:GetAssignedHero()
  if (not hero) then return end

  local talentId = tonumber(event.id)

  if BaseHero(hero) then BaseHero(hero):UpgradeRank(talentId) end
end

function TalentTree:OnTalentTreeStateRequest(event)
  if (not IsServer()) then return end
  if (not event or not event.PlayerID) then return end

  local player = PlayerResource:GetPlayer(event.PlayerID)
  if (not player) then return end

  local hero = player:GetAssignedHero()
  if (hero == nil) then return end

  if BaseHero(hero) == nil then return end

  BaseHero(hero):UpdatePanoramaState()
end

function TalentTree:OnTalentTreeResetRequest(event)
  if (not IsServer()) then return end
  if (event == nil or not event.PlayerID) then return end

  local player = PlayerResource:GetPlayer(event.PlayerID)
  if (not player) then return end

  local hero = player:GetAssignedHero()
  if (not hero) then return end

  if BaseHero(hero) == nil then return end

  local pointsToReturn = 0
  for i = 1, #base_hero.talentsData do
    pointsToReturn = pointsToReturn + base_hero:GetHeroTalentLevel(i)
    BaseHero(hero):SetHeroTalentLevel(i, 0)
  end

  BaseHero(hero):AddTalentPointsToHero(pointsToReturn)
end

function TalentTree:OnPlayerReconnect(keys)
  if (not IsServer()) then return end

  local player = EntIndexToHScript(keys.PlayerID)
  if (not player) then return end

  local hero = player:GetAssignedHero()
  if (not hero) then return end

  if BaseHero(hero) == nil then return end

  --BaseHero(hero):UpdatePanoramaPanels()
  BaseHero(hero):UpdatePanoramaState()
end

TalentTree:Init()