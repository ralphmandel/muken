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
    CustomGameEventManager:RegisterListener("portrait_unit_update", Dynamic_Wrap(TalentTree, 'OnPortraitUpdate'))
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
    crit_damage = BaseStats(entity):GetCriticalDamage(),
    crit_chance = BaseStats(entity):GetCriticalChance(),
    attack_speed = entity:GetDisplayAttackSpeed(),
    magical_damage = BaseStats(entity):GetTotalMagicalDamagePercent(),
    debuff_amp = BaseStats(entity):GetTotalDebuffAmpPercent(),
    mp_regen = entity:GetManaRegen(),
    cd_reduction = entity:GetCooldownReduction() * 100,
    movespeed = entity:GetIdealSpeed(),
    evasion = BaseStats(entity):GetDodgePercent(),
    armor = entity:GetPhysicalArmorValue(false),
    hp_regen = entity:GetHealthRegen(),
    magical_resist = entity:Script_GetMagicalArmorValue(false, BaseStats(entity)) * 100,
    status_resist = BaseStats(entity):GetStatusResistPercent(),
    heal_power = BaseStats(entity):GetTotalHealPowerPercent(),
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

    if BaseHero(hero) == nil then return end

    local talentId = tonumber(event.id)
    if (not talentId or talentId < 1 or talentId > #BaseHero(hero).talentsData) then return end
    if not BaseHero(hero).talents then return end

    if BaseHero(hero):IsHeroCanLevelUpTalent(talentId) then
      local MaxTalentLvl = BaseHero(hero):GetTalentMaxLevel(talentId)
      local talentLvl = BaseHero(hero):GetHeroTalentLevel(talentId)
      if MaxTalentLvl == 6 then
        BaseHero(hero):AddTalentPointsToHero(-1)
        BaseHero(hero):SetHeroTalentLevel(talentId, talentLvl + 1)
      else
        BaseHero(hero):AddTalentPointsToHero(-MaxTalentLvl)
        BaseHero(hero):SetHeroTalentLevel(talentId, MaxTalentLvl)
      end
    end
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