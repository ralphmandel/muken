if GameSetup == nil then
  GameSetup = class({})
end

-- nil will not force a hero selection
local forceHero = nil

-- require('libraries/keyvalues')
-- require('libraries/modifiers')
require('libraries/timers')
require('libraries/wearables')
--require('libraries/wearables_warmful_ancient')


function GameSetup:init()
    if IsInToolsMode() then -- debug build
        GameRules:SetStartingGold(99999)
    else
        GameRules:SetStartingGold(90)
    end
    -- skip all the starting game mode stages e.g picking screen, showcase, etc
    --GameRules:EnableCustomGameSetupAutoLaunch(true)
    --GameRules:SetCustomGameSetupAutoLaunchDelay(0)
    GameRules:SetHeroSelectionTime(30)
    GameRules:SetStrategyTime(0)
    GameRules:SetPreGameTime(60)
    GameRules:SetShowcaseTime(0)
    GameRules:SetPostGameTime(5)
    GameRules:SetSafeToLeave(true)
    GameRules:SetTimeOfDay(0.25)
    GameRules:SetTreeRegrowTime(60)
    GameRules:SetFirstBloodActive(true)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_GOODGUYS, 0)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_BADGUYS, 0)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_1, 4)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_2, 4)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_3, 4)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_4, 4)
    GameRules:SetCustomGameTeamMaxPlayers(DOTA_TEAM_CUSTOM_5, 4)
    SetTeamCustomHealthbarColor(DOTA_TEAM_NEUTRALS, 248, 248, 255)
    SetTeamCustomHealthbarColor(DOTA_TEAM_CUSTOM_1, 0, 153, 0)
    SetTeamCustomHealthbarColor(DOTA_TEAM_CUSTOM_2, 153, 0, 0)
    SetTeamCustomHealthbarColor(DOTA_TEAM_CUSTOM_3, 204, 153, 0)
    SetTeamCustomHealthbarColor(DOTA_TEAM_CUSTOM_4, 0, 153, 204)
    SetTeamCustomHealthbarColor(DOTA_TEAM_CUSTOM_5, 153, 0, 204)

    --GameRules:SetUseBaseGoldBountyOnHeroes(false)

    -- disable some setting which are annoying then testing
    local GameMode = GameRules:GetGameModeEntity()
    GameMode:SetTPScrollSlotItemOverride("item_tp")
    GameMode:SetGiveFreeTPOnDeath(false)
    GameMode:SetBuybackEnabled(false)
    GameMode:SetDaynightCycleAdvanceRate(1)
    GameMode:SetDaynightCycleDisabled(false)
	XP_PER_LEVEL_TABLE = {
		30, 40, 50, 60, 70,
		83, 96, 109, 122, 135,
		152, 169, 186, 203, 220,
		242, 264, 286, 308, 330
	}
    GameMode:SetCustomXPRequiredToReachNextLevel(XP_PER_LEVEL_TABLE)
    GameMode:SetUseCustomHeroLevels(true)
    GameMode:SetFixedRespawnTime(30)
    GameMode:SetModifyGoldFilter(Dynamic_Wrap(self, "FilterModifyGold"), self)
    GameMode:SetModifyExperienceFilter(Dynamic_Wrap(self, "FilterModifyExperience"), self)
    GameMode:SetCustomScanCooldown(60)
    GameMode:SetNeutralStashEnabled(false)
    GameMode:SetInnateMeleeDamageBlockAmount(0)
    GameMode:SetAnnouncerDisabled(true)
    GameMode:SetKillingSpreeAnnouncerDisabled(true)
    --GameMode:SetSendToStashEnabled(true)
    --GameMode:SetNeutralStashEnabled(true)

    -- disable HUDs hud
    --GameMode:SetHUDVisible(DOTA_HUD_VISIBILITY_INVENTORY_ITEMS , false)
    GameMode:SetHUDVisible(DOTA_HUD_VISIBILITY_TOP_SCOREBOARD, false)
    GameMode:SetHUDVisible(DOTA_HUD_VISIBILITY_TOP_HEROES, false)
    -- GameMode:SetHUDVisible(DOTA_HUD_VISIBILITY_QUICK_STATS, false)
    -- GameMode:SetHUDVisible(DOTA_HUD_VISIBILITY_QUICK_STATS, false)
    -- GameMode:SetHUDVisible(DOTA_HUD_VISIBILITY_QUICK_STATS, false)

    -- disable music events
    GameRules:SetCustomGameAllowHeroPickMusic(false)
    GameRules:SetCustomGameAllowMusicAtGameStart(false)
    GameRules:SetCustomGameAllowBattleMusic(false)

    -- multiple players can pick the same hero
    GameRules:SetSameHeroSelectionEnabled(false)

    -- force single hero selection (optional)
    if forceHero ~= nil then
        GameMode:SetCustomGameForceHero(forceHero)
    end

    -- listen to game state event
    ListenToGameEvent("game_rules_state_change", Dynamic_Wrap(self, "OnStateChange"), self)

    -- Gold Rules
    GameMode:SetLoseGoldOnDeath(false)
    GameMode:SetSelectionGoldPenaltyEnabled(false)
    GameMode:SetMaximumAttackSpeed(900)
    GameRules:SetGoldPerTick(0)
    GameRules:SetGoldTickTime(0)
end

function GameSetup:OnStateChange()
    -- random hero once we reach strategy phase
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_STRATEGY_TIME then
        GameSetup:RandomForNoHeroSelected()
    end
end

function GameSetup:RandomForNoHeroSelected()
    -- NOTE: GameRules state must be in HERO_SELECTION or STRATEGY_TIME to pick heroes
    -- loop through each player on every team and random a hero if they haven't picked

    local maxPlayers = 5
    local teams = {
        [1] = DOTA_TEAM_CUSTOM_1,
        [2] = DOTA_TEAM_CUSTOM_2,
        [3] = DOTA_TEAM_CUSTOM_3,
        [4] = DOTA_TEAM_CUSTOM_4,
        [5] = DOTA_TEAM_CUSTOM_5,
    }

    for _, teamNum in pairs(teams) do
        for i = 1, maxPlayers do
            local playerID = PlayerResource:GetNthPlayerIDOnTeam(teamNum, i)
            if playerID ~= nil then
                if not PlayerResource:HasSelectedHero(playerID) then
                    local hPlayer = PlayerResource:GetPlayer(playerID)
                    if hPlayer ~= nil then
                        hPlayer:MakeRandomHeroSelection()
                    end
                end
            end
        end
    end
end
