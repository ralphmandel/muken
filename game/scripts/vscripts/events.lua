-- This file contains all barebones-registered events and has already set up the passed-in parameters for your use.

-- Cleanup a player when they leave
function GameMode:OnDisconnect(keys)
  DebugPrint('[BAREBONES] Player Disconnected ' .. tostring(keys.userid))
  DebugPrintTable(keys)

  local name = keys.name
  local networkid = keys.networkid
  local reason = keys.reason
  local userid = keys.userid

end
-- The overall game state has changed
function GameMode:OnGameRulesStateChange(keys)
  DebugPrint("[BAREBONES] GameRules State Changed")
  DebugPrintTable(keys)

  local newState = GameRules:State_Get()

  if newState == DOTA_GAMERULES_STATE_PRE_GAME then
    if IsInToolsMode() then
      --LoadBots()
      AddFOWViewer(DOTA_TEAM_CUSTOM_5, Vector(0, 0, 0), 5000, 9999, false)
    else
      LoadBots()
    end
  end
end

-- An NPC has spawned somewhere in game.  This includes heroes
function GameMode:OnNPCSpawned(keys)
  DebugPrint("[BAREBONES] NPC Spawned")
  DebugPrintTable(keys)

  local npc = EntIndexToHScript(keys.entindex)
  if npc then
    if npc:IsHero() and npc:IsReincarnating() == false and npc:IsIllusion() == false then
      Spawner:RandomizePlayerSpawn(npc)
      
      local playerID = npc:GetPlayerOwnerID()
      if playerID ~= nil then
        CenterCameraOnUnit(playerID, npc)
      end
    end
  end
end

-- An entity somewhere has been hurt.  This event fires very often with many units so don't do too many expensive
-- operations here
function GameMode:OnEntityHurt(keys)
  --DebugPrint("[BAREBONES] Entity Hurt")
  --DebugPrintTable(keys)

  local damagebits = keys.damagebits -- This might always be 0 and therefore useless
  if keys.entindex_attacker ~= nil and keys.entindex_killed ~= nil then
    local entCause = EntIndexToHScript(keys.entindex_attacker)
    local entVictim = EntIndexToHScript(keys.entindex_killed)

    -- The ability/item used to damage, or nil if not damaged by an item/ability
    local damagingAbility = nil

    if keys.entindex_inflictor ~= nil then
      damagingAbility = EntIndexToHScript( keys.entindex_inflictor )
    end
  end
end

-- An item was picked up off the ground
function GameMode:OnItemPickedUp(keys)
  DebugPrint( '[BAREBONES] OnItemPickedUp' )
  DebugPrintTable(keys)

  local unitEntity = nil
  if keys.UnitEntitIndex then
    unitEntity = EntIndexToHScript(keys.UnitEntitIndex)
  elseif keys.HeroEntityIndex then
    unitEntity = EntIndexToHScript(keys.HeroEntityIndex)
  end

  local itemEntity = EntIndexToHScript(keys.ItemEntityIndex)
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local itemname = keys.itemname
end

-- A player has reconnected to the game.  This function can be used to repaint Player-based particles or change
-- state as necessary
function GameMode:OnPlayerReconnect(keys)
  DebugPrint( '[BAREBONES] OnPlayerReconnect' )
  DebugPrintTable(keys) 
end

-- An item was purchased by a player
function GameMode:OnItemPurchased( keys )
  DebugPrint( '[BAREBONES] OnItemPurchased' )
  DebugPrintTable(keys)

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end

  -- The name of the item purchased
  local itemName = keys.itemname 
  
  -- The cost of the item purchased
  local itemcost = keys.itemcost
  
end

-- An ability was used by a player
function GameMode:OnAbilityUsed(keys)
  DebugPrint('[BAREBONES] AbilityUsed')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local abilityname = keys.abilityname
end

-- A non-player entity (necro-book, chen creep, etc) used an ability
function GameMode:OnNonPlayerUsedAbility(keys)
  DebugPrint('[BAREBONES] OnNonPlayerUsedAbility')
  DebugPrintTable(keys)

  local abilityname=  keys.abilityname
end

-- A player changed their name
function GameMode:OnPlayerChangedName(keys)
  DebugPrint('[BAREBONES] OnPlayerChangedName')
  DebugPrintTable(keys)

  local newName = keys.newname
  local oldName = keys.oldName
end

-- A player leveled up an ability
function GameMode:OnPlayerLearnedAbility( keys)
  DebugPrint('[BAREBONES] OnPlayerLearnedAbility')
  DebugPrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local abilityname = keys.abilityname
end

-- A channelled ability finished by either completing or being interrupted
function GameMode:OnAbilityChannelFinished(keys)
  DebugPrint('[BAREBONES] OnAbilityChannelFinished')
  DebugPrintTable(keys)

  local abilityname = keys.abilityname
  local interrupted = keys.interrupted == 1
end

-- A player leveled up
function GameMode:OnPlayerLevelUp(keys)
  DebugPrint('[BAREBONES] OnPlayerLevelUp')
  DebugPrintTable(keys)

  local player = EntIndexToHScript(keys.player)
  local level = keys.level
end

-- A player last hit a creep, a tower, or a hero
function GameMode:OnLastHit(keys)
  DebugPrint('[BAREBONES] OnLastHit')
  DebugPrintTable(keys)

  local isFirstBlood = keys.FirstBlood == 1
  local isHeroKill = keys.HeroKill == 1
  local isTowerKill = keys.TowerKill == 1
  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local killedEnt = EntIndexToHScript(keys.EntKilled)
end

-- A tree was cut down by tango, quelling blade, etc
function GameMode:OnTreeCut(keys)
  DebugPrint('[BAREBONES] OnTreeCut')
  DebugPrintTable(keys)

  local treeX = keys.tree_x
  local treeY = keys.tree_y

  for _, hero in pairs(HeroList:GetAllHeroes()) do
    local seed = hero:FindAbilityByName("druid_5__seed")
    if seed then
      if seed:IsTrained() then
        seed:OnTreeCut(Vector(treeX, treeY, 100))
      end
    end
  end
end

-- A rune was activated by a player
function GameMode:OnRuneActivated (keys)
  DebugPrint('[BAREBONES] OnRuneActivated')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local rune = keys.rune

  --[[ Rune Can be one of the following types
  DOTA_RUNE_DOUBLEDAMAGE
  DOTA_RUNE_HASTE
  DOTA_RUNE_HAUNTED
  DOTA_RUNE_ILLUSION
  DOTA_RUNE_INVISIBILITY
  DOTA_RUNE_BOUNTY
  DOTA_RUNE_MYSTERY
  DOTA_RUNE_RAPIER
  DOTA_RUNE_REGENERATION
  DOTA_RUNE_SPOOKY
  DOTA_RUNE_TURBO
  ]]
end

-- A player took damage from a tower
function GameMode:OnPlayerTakeTowerDamage(keys)
  DebugPrint('[BAREBONES] OnPlayerTakeTowerDamage')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local damage = keys.damage
end

-- A player picked a hero
function GameMode:OnPlayerPickHero(keys)
  DebugPrint('[BAREBONES] OnPlayerPickHero')
  DebugPrintTable(keys)

  local heroClass = keys.hero
  local heroEntity = EntIndexToHScript(keys.heroindex)
  local player = EntIndexToHScript(keys.player)
end

-- A player killed another player in a multi-team context
function GameMode:OnTeamKillCredit(keys)
  DebugPrint('[BAREBONES] OnTeamKillCredit')
  DebugPrintTable(keys)

  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local victimPlayer = PlayerResource:GetPlayer(keys.victim_userid)
  local numKills = keys.herokills
  local killerTeamNumber = keys.teamnumber
  local KillerTeamIndex = GetTeamIndex(killerTeamNumber)
  local VictimTeamIndex = GetTeamIndex(victimPlayer:GetAssignedHero():GetTeamNumber())

  TEAMS[VictimTeamIndex][2] = TEAMS[VictimTeamIndex][2] + SCORE_DEATH
  if TEAMS[VictimTeamIndex][2] < 0 then TEAMS[VictimTeamIndex][2] = 0 end
  local message = TEAMS[VictimTeamIndex][3] .. " SCORE: " .. TEAMS[VictimTeamIndex][2]
  GameRules:SendCustomMessage(TEAMS[VictimTeamIndex][5] .. message .."</font>",-1,0)

  TEAMS[KillerTeamIndex][2] = TEAMS[KillerTeamIndex][2] + SCORE_KILL
  local message = TEAMS[KillerTeamIndex][3] .. " SCORE: " .. TEAMS[KillerTeamIndex][2]
  GameRules:SendCustomMessage(TEAMS[KillerTeamIndex][5] .. message .."</font>",-1,0)

  if TEAMS[KillerTeamIndex][2] >= SCORE_LIMIT then
    local message = TEAMS[KillerTeamIndex][3] .. " VICTORY!"
    GameRules:SetCustomVictoryMessage(message)
    GameRules:SetGameWinner(TEAMS[KillerTeamIndex][1])
  end

  -- if victimPlayer:GetAssignedHero():IsReincarnating() == false then
  --   if self.first_blood == nil then self.first_blood = true end
  --   if self.vo == nil then self.vo = 0 end
  --   if self.vo_time == nil then self.vo_time = -60 end

  --   if self.first_blood == true then
  --     EmitAnnouncerSound("announcer_killing_spree_announcer_1stblood_01")
  --     self.first_blood = false
  --   end

  --   if math.floor(GameRules:GetDOTATime(false, true)) >= self.vo_time then
  --     if RandomInt(1,2) > 1 then
  --       self.vo = self.vo + 1
  --       Timers:CreateTimer((2), function()
  --         self.vo = self.vo - 1
  --         if self.vo == 0 then
  --           local rand_vo = RandomInt(1, 4)
  --           if rand_vo == 1 then
  --             EmitAnnouncerSound("Vo.Kill.1")
  --             self.vo_time = math.floor(GameRules:GetDOTATime(false, true)) + 8
  --           elseif rand_vo == 2 then
  --             EmitAnnouncerSound("Vo.Kill.2")
  --             self.vo_time = math.floor(GameRules:GetDOTATime(false, true)) + 3
  --           elseif rand_vo == 3 then
  --             EmitAnnouncerSound("Vo.Kill.3")
  --             self.vo_time = math.floor(GameRules:GetDOTATime(false, true)) + 28
  --           else
  --             EmitAnnouncerSound("Vo.Kill.4")
  --             self.vo_time = math.floor(GameRules:GetDOTATime(false, true)) + 6
  --           end
  --         end
  --       end)
  --     end
  --     for _,player in pairs(PLAYERS) do
  --       if player[1] == killer then
  --         player[2] = player[2] + 1
  --         local string = GetKillingSpreeAnnouncer(player[2])
  --         if player[2] > 2 then EmitAnnouncerSound(string) end
  --         break
  --       end
  --     end
  --   end
  -- end
end

-- An entity died
function GameMode:OnEntityKilled( keys )
  DebugPrint( '[BAREBONES] OnEntityKilled Called' )
  DebugPrintTable( keys )  

  -- The Unit that was Killed
  local killedUnit = EntIndexToHScript( keys.entindex_killed )
  -- The Killing entity
  local killerEntity = nil

  if keys.entindex_attacker ~= nil then
    killerEntity = EntIndexToHScript( keys.entindex_attacker )
  end

  -- The ability/item used to kill, or nil if not killed by an item/ability
  local killerAbility = nil

  if keys.entindex_inflictor ~= nil then
    killerAbility = EntIndexToHScript( keys.entindex_inflictor )
  end

  local damagebits = keys.damagebits -- This might always be 0 and therefore useless
  -- print("IsIllusion", killedUnit:IsIllusion())
  -- print("IsConsideredHero", killedUnit:IsConsideredHero())
  -- print("IsHero", killedUnit:IsHero())
  -- print("IsCreature", killedUnit:IsCreature())
  -- print("IsNeutralUnitType", killedUnit:IsNeutralUnitType())

  -- Put code here to handle when an entity gets killed
  if killedUnit:IsReincarnating() == false then
    if self.vo == nil then self.vo = 0 end
    if self.vo_time == nil then self.vo_time = -60 end

    if killedUnit:IsHero() == false then
      if killedUnit:IsNeutralUnitType() then
        if IsServer() then killedUnit:EmitSound("Creature.Kill") end
      end

      if killedUnit:GetTeamNumber() == DOTA_TEAM_NEUTRALS then
        RollDrops(killedUnit, killerEntity)

        if killerAbility == nil and killerEntity ~= nil then
          if killerEntity:GetPlayerOwner() ~= nil then
            if killerEntity:GetPlayerOwner():GetAssignedHero() ~= nil then
              local gold = 0
              local number = 0

              local allies = FindUnitsInRadius(
                killerEntity:GetPlayerOwner():GetAssignedHero():GetTeamNumber(),
                killedUnit:GetOrigin(), nil, 750, DOTA_UNIT_TARGET_TEAM_FRIENDLY,
                DOTA_UNIT_TARGET_HERO, DOTA_UNIT_TARGET_FLAG_NOT_CREEP_HERO, 0, false
              )
            
              for _,ally in pairs(allies) do
                if ally:IsIllusion() == false then
                  number = number + 1
                end
              end
            
              local average_gold_bounty = RandomInt(XP_BOUNTY_MIN * killedUnit:GetLevel(), XP_BOUNTY_MAX * killedUnit:GetLevel())
              gold = average_gold_bounty / number
            
              if math.floor(gold) > 0 and number > 0 then
                for _,ally in pairs(allies) do
                  if ally:IsIllusion() == false then
                    ally:ModifyGold(math.floor(gold), false, 18)
                    SendOverheadEventMessage(ally:GetPlayerOwner(), OVERHEAD_ALERT_GOLD, ally, gold, ally)
                    --if BaseHero(ally) then BaseHero(ally):AddGold(gold) end
                    ally:AddExperience(gold, 0, false, false)
                  end
                end
              end              
            end
          end
        end
      end
    else
      for _,player in pairs(PLAYERS) do
        if player[1]:GetAssignedHero() == killedUnit
        and killerAbility == nil and killerEntity ~= nil then
          player[2] = 0
    
          if killerEntity:GetTeamNumber() == DOTA_TEAM_NEUTRALS
          and math.floor(GameRules:GetDOTATime(false, true)) >= self.vo_time then
            self.vo = self.vo + 1
            Timers:CreateTimer((1.5), function()
              self.vo = self.vo - 1
              if self.vo == 0 then
                EmitAnnouncerSound("Vo.Suicide")
                self.vo_time = math.floor(GameRules:GetDOTATime(false, true)) + 3
              end
            end)
          end
        end
      end
    end
  end
end



-- This function is called 1 to 2 times as the player connects initially but before they 
-- have completely connected
function GameMode:PlayerConnect(keys)
  DebugPrint('[BAREBONES] PlayerConnect')
  DebugPrintTable(keys)
end

-- This function is called once when the player fully connects and becomes "Ready" during Loading
function GameMode:OnConnectFull(keys)
  DebugPrint('[BAREBONES] OnConnectFull')
  DebugPrintTable(keys)
  
  --local entIndex = keys.index+1
  local entIndex = keys.index
  -- The Player entity of the joining user
  local ply = EntIndexToHScript(entIndex)

  -- The Player ID of the joining player
  local playerID = ply:GetPlayerID()
end

-- This function is called whenever illusions are created and tells you which was/is the original entity
function GameMode:OnIllusionsCreated(keys)
  DebugPrint('[BAREBONES] OnIllusionsCreated')
  DebugPrintTable(keys)

  local originalEntity = EntIndexToHScript(keys.original_entindex)
end

-- This function is called whenever an item is combined to create a new item
function GameMode:OnItemCombined(keys)
  DebugPrint('[BAREBONES] OnItemCombined')
  DebugPrintTable(keys)

  -- The playerID of the hero who is buying something
  local plyID = keys.PlayerID
  if not plyID then return end
  local player = PlayerResource:GetPlayer(plyID)

  -- The name of the item purchased
  local itemName = keys.itemname 
  
  -- The cost of the item purchased
  local itemcost = keys.itemcost
end

-- This function is called whenever an ability begins its PhaseStart phase (but before it is actually cast)
function GameMode:OnAbilityCastBegins(keys)
  DebugPrint('[BAREBONES] OnAbilityCastBegins')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.PlayerID)
  local abilityName = keys.abilityname
end

-- This function is called whenever a tower is killed
function GameMode:OnTowerKill(keys)
  DebugPrint('[BAREBONES] OnTowerKill')
  DebugPrintTable(keys)

  local gold = keys.gold
  local killerPlayer = PlayerResource:GetPlayer(keys.killer_userid)
  local team = keys.teamnumber
end

-- This function is called whenever a player changes there custom team selection during Game Setup 
function GameMode:OnPlayerSelectedCustomTeam(keys)
  DebugPrint('[BAREBONES] OnPlayerSelectedCustomTeam')
  DebugPrintTable(keys)

  local player = PlayerResource:GetPlayer(keys.player_id)
  local success = (keys.success == 1)
  local team = keys.team_id
end

-- This function is called whenever an NPC reaches its goal position/target
function GameMode:OnNPCGoalReached(keys)
  DebugPrint('[BAREBONES] OnNPCGoalReached')
  DebugPrintTable(keys)

  local goalEntity = EntIndexToHScript(keys.goal_entindex)
  local nextGoalEntity = EntIndexToHScript(keys.next_goal_entindex)
  local npc = EntIndexToHScript(keys.npc_entindex)
end

-- This function is called whenever any player sends a chat message to team or All
function GameMode:OnPlayerChat(keys)
  local teamonly = keys.teamonly
  local userID = keys.userid
  local playerID = self.vUserIds[userID]:GetPlayerID()

  local text = keys.text
end