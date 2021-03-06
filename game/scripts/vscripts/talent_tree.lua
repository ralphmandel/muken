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
end

function TalentTree:OnTalentTreeTalentsRequest(event)
    if (not event or not event.PlayerID) then return end
    
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (not player) then return end

    local hero = player:GetAssignedHero()
    if (not hero) then return end

    local base_hero = hero:FindAbilityByName("base_hero")
    if (not base_hero) then return end

    base_hero:UpdatePanoramaPanels()
end

function TalentTree:OnTalentTreeLevelUpRequest(event)
    if (not IsServer()) then return end
    if (event == nil or not event.PlayerID) then return end

    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (not player) then return end

    local hero = player:GetAssignedHero()
    if (not hero) then return end

    local base_hero = hero:FindAbilityByName("base_hero")
    if (not base_hero) then return end

    local talentId = tonumber(event.id)
    if (not talentId or talentId < 1 or talentId > #base_hero.talentsData) then return end
    if not base_hero.talents then return end

    if base_hero:IsHeroCanLevelUpTalent(talentId) then
        local MaxTalentLvl = base_hero:GetTalentMaxLevel(talentId)
        local talentLvl = base_hero:GetHeroTalentLevel(talentId)
        if MaxTalentLvl == 6 then
            base_hero:AddTalentPointsToHero(-1)
            base_hero:SetHeroTalentLevel(talentId, talentLvl + 1)
        else
            base_hero:AddTalentPointsToHero(-MaxTalentLvl)
            base_hero:SetHeroTalentLevel(talentId, MaxTalentLvl)
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

    local base_hero = hero:FindAbilityByName("base_hero")
    if (not base_hero) then return end

    base_hero:UpdatePanoramaState()
end

function TalentTree:OnTalentTreeResetRequest(event)
    if (not IsServer()) then return end
    if (event == nil or not event.PlayerID) then return end

    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (not player) then return end

    local hero = player:GetAssignedHero()
    if (not hero) then return end

    local base_hero = hero:FindAbilityByName("base_hero")
    if (not base_hero) then return end

    local pointsToReturn = 0
    for i = 1, #base_hero.talentsData do
        pointsToReturn = pointsToReturn + base_hero:GetHeroTalentLevel(i)
        base_hero:SetHeroTalentLevel(i, 0)
    end

    base_hero:AddTalentPointsToHero(pointsToReturn)
end

function TalentTree:OnPlayerReconnect(keys)
    if (not IsServer()) then return end

    local player = EntIndexToHScript(keys.PlayerID)
    if (not player) then return end

    local hero = player:GetAssignedHero()
    if (not hero) then return end

    local base_hero = hero:FindAbilityByName("base_hero")
    if (not base_hero) then return end

    base_hero:UpdatePanoramaPanels()
    base_hero:UpdatePanoramaState()
end

TalentTree:Init()