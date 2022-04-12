if (not _G.TalentTree) then
    _G.TalentTree = class({})
end

function TalentTree:Init()
    if (not IsServer()) then
        return
    end

    if TalentTree.initializated == nil then
        TalentTree.initializated = true
        TalentTree:InitPanaromaEvents()
    end

    ListenToGameEvent("player_reconnected", Dynamic_Wrap(self, "OnPlayerReconnect"), self)
end

function TalentTree:InitPanaromaEvents()
    CustomGameEventManager:RegisterListener("talent_tree_get_talents", Dynamic_Wrap(TalentTree, 'OnTalentTreeTalentsRequest'))
    CustomGameEventManager:RegisterListener("talent_tree_level_up_talent", Dynamic_Wrap(TalentTree, 'OnTalentTreeLevelUpRequest'))
    CustomGameEventManager:RegisterListener("talent_tree_get_state", Dynamic_Wrap(TalentTree, 'OnTalentTreeStateRequest'))
    CustomGameEventManager:RegisterListener("talent_tree_reset_talents", Dynamic_Wrap(TalentTree, 'OnTalentTreeResetRequest'))
end

function TalentTree:ResetData(hero)
    if (not hero) then
        return
    end

    local data
    if hero:GetUnitName() == "npc_dota_hero_riki" then
        self.abilitiesData = LoadKeyValues("scripts/vscripts/heroes/icebreaker/icebreaker.txt")
        data = LoadKeyValues("scripts/vscripts/heroes/icebreaker/icebreaker-ranks.txt")
        hero.att = "icebreaker__attributes"
    elseif hero:GetUnitName() == "npc_dota_hero_shadow_demon" then
        self.abilitiesData = LoadKeyValues("scripts/vscripts/heroes/bloodstained/bloodstained.txt")
        data = LoadKeyValues("scripts/vscripts/heroes/bloodstained/bloodstained-ranks.txt")
        hero.att = "bloodstained__attributes"
    elseif hero:GetUnitName() == "npc_dota_hero_phantom_assassin" then
        self.abilitiesData = LoadKeyValues("scripts/vscripts/heroes/shadow/shadow.txt")
        data = LoadKeyValues("scripts/vscripts/heroes/shadow/shadow-ranks.txt")
        hero.att = "shadow__attributes"
    elseif hero:GetUnitName() == "npc_dota_hero_dawnbreaker" then
        self.abilitiesData = LoadKeyValues("scripts/vscripts/heroes/inquisitor/inquisitor.txt")
        data = LoadKeyValues("scripts/vscripts/heroes/inquisitor/inquisitor-ranks.txt")
        hero.att = "inquisitor__attributes"
    elseif hero:GetUnitName() == "npc_dota_hero_abaddon" then
        self.abilitiesData = LoadKeyValues("scripts/vscripts/heroes/crusader/crusader.txt")
        data = LoadKeyValues("scripts/vscripts/heroes/crusader/crusader-ranks.txt")
        hero.att = "crusader__attributes"
    elseif hero:GetUnitName() == "npc_dota_hero_pudge" then
        self.abilitiesData = LoadKeyValues("scripts/vscripts/heroes/bocuse/bocuse.txt")
        data = LoadKeyValues("scripts/vscripts/heroes/bocuse/bocuse-ranks.txt")
        hero.att = "bocuse__attributes"
    elseif hero:GetUnitName() == "npc_dota_hero_shadow_shaman" then
        self.abilitiesData = LoadKeyValues("scripts/vscripts/heroes/dasdingo/dasdingo.txt")
        data = LoadKeyValues("scripts/vscripts/heroes/dasdingo/dasdingo-ranks.txt")
        hero.att = "dasdingo__attributes"
    elseif hero:GetUnitName() == "npc_dota_hero_razor" then
        self.abilitiesData = LoadKeyValues("scripts/vscripts/heroes/slayer/slayer.txt")
        data = LoadKeyValues("scripts/vscripts/heroes/slayer/slayer-ranks.txt")
        hero.att = "slayer__attributes"
    elseif hero:GetUnitName() == "npc_dota_hero_bloodseeker" then
        self.abilitiesData = LoadKeyValues("scripts/vscripts/heroes/bloodmage/bloodmage.txt")
        data = LoadKeyValues("scripts/vscripts/heroes/bloodmage/bloodmage-ranks.txt")
        hero.att = "bloodmage__attributes"
    elseif hero:GetUnitName() == "npc_dota_hero_furion" then
        self.abilitiesData = LoadKeyValues("scripts/vscripts/heroes/druid/druid.txt")
        data = LoadKeyValues("scripts/vscripts/heroes/druid/druid-ranks.txt")
        hero.att = "druid__attributes"
    elseif hero:GetUnitName() == "npc_dota_hero_elder_titan" then
        self.abilitiesData = LoadKeyValues("scripts/vscripts/heroes/ancient/ancient.txt")
        data = LoadKeyValues("scripts/vscripts/heroes/ancient/ancient-ranks.txt")
        hero.att = "ancient__attributes"
    elseif hero:GetUnitName() == "npc_dota_hero_rubick" then
        self.abilitiesData = LoadKeyValues("scripts/vscripts/heroes/doctor/doctor.txt")
        data = LoadKeyValues("scripts/vscripts/heroes/doctor/doctor-ranks.txt")
        hero.att = "doctor__attributes"
    end

    hero.talentsData = {}
    hero.tabs = {}
    hero.rows = {}
	
	for _,unit in pairs(data) do
		if not unit["min_level"] then
            local att = hero:FindAbilityByName(hero.att)
            if (not att) then return false end
            for i = 1, 5, 1 do
                for tabName, tabData in pairs(unit) do
                    local isTab = false
                    if i == 5 then
                        if tabName == "extras" then
                            isTab = true
                        end
                    else
                        if tabName == att.skills[i] then
                            isTab = true
                        end
                    end

                    if isTab == true then
                        table.insert(hero.tabs, tabName)
                        for nlvl, talents in pairs(tabData) do
                            table.insert(hero.rows, tonumber(nlvl))
                            for _, talent in pairs(talents) do
        
                                local talentData = {
                                    Ability = talent,
                                    Tab = tabName,
                                    NeedLevel = tonumber(nlvl)
                                }
                                if self.abilitiesData[talent] then
                                    talentData.MaxLevel = self.abilitiesData[talent]["MaxLevel"] or 1
                                else
                                    talentData.MaxLevel = 1
                                end
                                table.insert(hero.talentsData, talentData)
                            end
                        end
                    end 
                end
            end
		end
	end
	
    local loclenght = 1
    local locarr = {}
    table.sort(hero.rows)
    for i = 1, #hero.rows do
        if locarr[hero.rows[i]] == nil then
            locarr[hero.rows[i]] = loclenght
            loclenght = loclenght + 1
        end
    end
    hero.rows = locarr

    self.talentData = data
end

function TalentTree:GetColumnTalentPoints(hero, tab)
    local points = 0
    if hero and hero.talents then
        for talentId, lvl in pairs(hero.talents.level) do
            if hero.talentsData[talentId].Tab == tab then
                points = points + lvl
            end
        end
    end
    return points
end

function TalentTree:GetLatestTalentID(hero)
    return #hero.talentsData
end

function TalentTree:SetupForHero(hero)
    if (not hero) then
        return
    end

    local player = hero:GetPlayerOwner()
    if (not player) then
        return
    end

    TalentTree:ResetData(hero)

    hero.talents = {}
    hero.talents.level = {}
    hero.talents.abilities = {}
    for i = 1, TalentTree:GetLatestTalentID(hero) do
        hero.talents.level[i] = 0
    end
    hero.talents.currentPoints = 0

    CustomGameEventManager:Send_ServerToPlayer(player, "talent_tree_get_talents_from_server", {talents = hero.talentsData, tabs = hero.tabs, rows = hero.rows})
end

function TalentTree:GetHeroCurrentTalentPoints(hero)
    if (not hero or not hero.talents) then
        return 0
    end

    local points = 0
    local mod = hero:FindModifierByName("rank_points")
    if mod then points = mod:GetStackCount() end
    return points
end

function TalentTree:AddTalentPointsToHero(hero, points)
    if (not hero or not hero.talents) then
        return false
    end
    points = tonumber(points)
    if (not points) then
        return false
    end

    local mod = hero:FindModifierByName("rank_points")
    if mod then mod:SetStackCount(mod:GetStackCount() + points ) end

    TalentTree:OnTalentTreeStateRequest({ PlayerID = hero:GetPlayerOwnerID() })
end

function TalentTree:IsHeroHaveTalentTree(hero)
    if (not hero) then
        return false
    end
    if (hero.talents) then
        return true
    end
    return false
end

function TalentTree:GetTalentTab(hero, talentId)
    if (hero.talentsData[talentId]) then
        return hero.talentsData[talentId].Tab
    end
    return -1
end

function TalentTree:GetTalentMaxLevel(hero, talentId)
    if (hero.talentsData[talentId]) then
        return hero.talentsData[talentId].MaxLevel
    end
    return -1
end

function TalentTree:GetHeroTalentLevel(hero, talentId)
    if (TalentTree:IsHeroHaveTalentTree(hero) == true and talentId and talentId > 0) then
        return hero.talents.level[talentId]
    end
    return 0
end

function TalentTree:SetHeroTalentLevel(hero, talentId, level)
    level = tonumber(level)
    if (hero.talents and talentId > 0 and level and level > -1) then
        hero.talents.level[talentId] = level
		-- remove
        if (level == 0) then
            if (hero.talents.abilities[talentId]) then
                hero.talents.abilities[talentId]:GetCaster():RemoveAbilityByHandle(hero.talents.abilities[talentId])
                hero.talents.abilities[talentId] = nil
            end
		-- level up
        else
            if (not hero.talents.abilities[talentId]) then
                local ability = hero:FindAbilityByName(hero.talentsData[talentId].Ability)
                if ability == nil then
                    hero.talents.abilities[talentId] = hero:AddAbility(hero.talentsData[talentId].Ability)
                    hero.talents.abilities[talentId]:UpgradeAbility(true)
                else
                    --ability:UpgradeAbility(true)
                    hero.talents.abilities[talentId] = ability
                    hero.talents.abilities[talentId]:UpgradeAbility(true)
                end

                local skill = hero.talents.abilities[talentId]:GetSpecialValueFor("skill")
                local id = hero.talents.abilities[talentId]:GetSpecialValueFor("id")
                local permanent = hero.talents.abilities[talentId]:GetSpecialValueFor("permanent")
                local att = hero:FindAbilityByName(hero.att)
                if att then att:UpgradeRank(skill, id, level) end

                if permanent == 0 then
                    hero.talents.abilities[talentId]:GetCaster():RemoveAbilityByHandle(hero.talents.abilities[talentId])
                    hero.talents.abilities[talentId] = nil
                end

            elseif(hero.talents.abilities[talentId]) then
                local skill = hero.talents.abilities[talentId]:GetSpecialValueFor("skill")
                local id = hero.talents.abilities[talentId]:GetSpecialValueFor("id")
                local att = hero:FindAbilityByName(hero.att)
                if att then att:UpgradeRank(skill, id, level) end

                hero.talents.abilities[talentId]:SetLevel(level)
            end
        end
        
        TalentTree:OnTalentTreeStateRequest({ PlayerID = hero:GetPlayerOwnerID() })
    end
end

function TalentTree:IsHeroCanLevelUpTalent(hero, talentId)
    if (not hero.talentsData[talentId]) then
        return false
    end

    -- STATS DISABLED |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
    -- if (TalentTree:GetTalentMaxLevel(hero, talentId) == 6) then
    --     local xp = 5
    --     if hero:GetCurrentXP() >= 140 then xp = xp - 1 end
    --     if hero:GetCurrentXP() >= 280 then xp = xp - 1 end
    --     if hero:GetCurrentXP() >= 420 then xp = xp - 1 end
    --     if hero:GetCurrentXP() >= 560 then xp = xp - 1 end
    --     if hero:GetCurrentXP() >= 700 then xp = xp - 1 end
    --     local max = TalentTree:GetTalentMaxLevel(hero, talentId) - xp
    --     if (TalentTree:GetHeroTalentLevel(hero, talentId) >= max) then
    --         return false
    --     end
    --     if (TalentTree:GetHeroCurrentTalentPoints(hero) <= 0) then
    --         return false
    --     end
    --     return true
    -- end

    local att = hero:FindAbilityByName(hero.att)
    if (not att) then return false end
    local mod_rank_points = hero:FindModifierByName("rank_points")
    if mod_rank_points == nil then return false end

    local level = hero.talentsData[talentId].NeedLevel + 1
    local points_level = TalentTree:GetHeroRankLevel(hero)
    local points_max_level = mod_rank_points.max_level
    local left = points_max_level - points_level - level

    if left < 5 and TalentTree:GetTotalTalents(hero, left) == 0 then
        if left == 1 then return false end
        if left == 2 then
            if TalentTree:GetTotalTalents(hero, 1) < 2 then return false end
        end
        if left == 3 then
            if (TalentTree:GetTotalTalents(hero, 2) == 0 or TalentTree:GetTotalTalents(hero, 1) == 0)
            and TalentTree:GetTotalTalents(hero, 1) < 3 then return false end
        end
        if left == 4 then
            if (TalentTree:GetTotalTalents(hero, 3) == 0 or TalentTree:GetTotalTalents(hero, 1) == 0)
            and (TalentTree:GetTotalTalents(hero, 2) == 0 or TalentTree:GetTotalTalents(hero, 1) < 2)
            and TalentTree:GetTotalTalents(hero, 2) < 2
            and TalentTree:GetTotalTalents(hero, 1) < 4 then return false end
        end
    end

    -- Ancient 2.31 requires skill 1
    if hero.talentsData[talentId].Ability == "ancient_2__leap_rank_31"
    and (not att.talents[1][0]) then
        return false
    end

    -- Ancient 4.31 requires skill 1
    if hero.talentsData[talentId].Ability == "ancient_u__final_rank_31"
    and (not att.talents[1][0]) then
        return false
    end

    -- Bocuse 4.22 requires skill 1
    if hero.talentsData[talentId].Ability == "bocuse_u__mise_rank_22"
    and (not att.talents[1][0]) then
        return false
    end

    for i = 1, 4, 1 do
        if hero.talentsData[talentId].Tab == att.skills[i]
        and (not att.talents[i][0]) then
            return false
        end
    end

    if hero.talentsData[talentId].Tab == "extras" then
        if (not att.talents[1][0]) or (not att.talents[2][0]) or (not att.talents[3][0]) or (not att.talents[4][0]) then
            return false
        else
            if att.extras_unlocked > 0 then
                if hero:GetLevel() < 15 then
                    return false
                end
            else
                if hero:GetLevel() < 10 then
                    return false
                end
            end
        end
    end

    if (TalentTree:GetHeroTalentLevel(hero, talentId) >= TalentTree:GetTalentMaxLevel(hero, talentId)) then
        return false
    end
    if (TalentTree:GetHeroCurrentTalentPoints(hero) < TalentTree:GetTalentMaxLevel(hero, talentId)) then
        return false
    end
    return true
end

function TalentTree:GetTotalTalents(hero, level)
    local total = 0
    if hero and hero.talentsData then
        for talentId,talent in pairs(hero.talentsData) do
            if (TalentTree:GetHeroTalentLevel(hero, talentId) < TalentTree:GetTalentMaxLevel(hero, talentId))
            and (talent.NeedLevel + 1) == level
            and talent.Ability ~= "empty" then
                total = total + 1
            end
        end
    end

    return total
end

function TalentTree:GetHeroRankLevel(hero)
    local rank = 0
    if hero and hero.talentsData then
        for talentId,talent in pairs(hero.talentsData) do
            rank = rank + TalentTree:GetHeroTalentLevel(hero, talentId)
        end
    end

    return rank
end

function TalentTree:OnTalentTreeResetRequest(event)
    if (not IsServer()) then
        return
    end
    if (event == nil or not event.PlayerID) then
        return
    end
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (not player) then
        return
    end
    local hero = player:GetAssignedHero()
    if (not hero) then
        return
    end
    if (TalentTree:IsHeroHaveTalentTree(hero) == false) then
        return
    end
    local pointsToReturn = 0
    for i = 1, TalentTree:GetLatestTalentID(hero) do
        pointsToReturn = pointsToReturn + TalentTree:GetHeroTalentLevel(hero, i)
        TalentTree:SetHeroTalentLevel(hero, i, 0)
    end
    TalentTree:AddTalentPointsToHero(hero, pointsToReturn)
end

function TalentTree:OnTalentTreeLevelUpRequest(event)
    if (not IsServer()) then
        return
    end
    if (event == nil or not event.PlayerID) then
        return
    end

    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (not player) then
        return
    end
    local hero = player:GetAssignedHero()
    if (not hero) then
        return
    end
    local talentId = tonumber(event.id)
    if (not talentId or talentId < 1 or talentId > TalentTree:GetLatestTalentID(hero)) then
        return
    end
    if not hero.talents then
        return
    end

    if TalentTree:IsHeroCanLevelUpTalent(hero, talentId) then--(TalentTree:IsHeroSpendEnoughPointsInColumnForTalent(hero, talentId) and TalentTree:IsHeroCanLevelUpTalent(hero, talentId)) then
        local MaxTalentLvl = TalentTree:GetTalentMaxLevel(hero, talentId)
        local talentLvl = TalentTree:GetHeroTalentLevel(hero, talentId)
        if MaxTalentLvl == 6 then
            TalentTree:AddTalentPointsToHero(hero, -1)
            TalentTree:SetHeroTalentLevel(hero, talentId, talentLvl + 1)
        else
            TalentTree:AddTalentPointsToHero(hero, -MaxTalentLvl)
            TalentTree:SetHeroTalentLevel(hero, talentId, MaxTalentLvl)
        end
    end
end

function TalentTree:OnTalentTreeStateRequest(event)
    if (not IsServer()) then
        return
    end
    if (not event or not event.PlayerID) then
        return
    end
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (not player) then
        return
    end
	
    Timers:CreateTimer(0, function()
        local hero = player:GetAssignedHero()
        if (hero == nil) then
            return 1.0
        end
		
        if not hero.talents then
            return 1.0
        end

        local resultTable = {}
        for i = 1, TalentTree:GetLatestTalentID(hero) do
		local talentLvl = TalentTree:GetHeroTalentLevel(hero, i)
		local talentMaxLvl = TalentTree:GetTalentMaxLevel(hero, i)
		
		local isDisabled = TalentTree:IsHeroCanLevelUpTalent(hero, i) == false--(TalentTree:IsHeroSpendEnoughPointsInColumnForTalent(hero, i) == false) or 
		local isUpgraded = false
            if (talentLvl == talentMaxLvl) then
				isDisabled = false
                isUpgraded = true
			end
			table.insert(resultTable, { id = i, disabled = isDisabled, upgraded = isUpgraded, level = talentLvl, maxlevel = talentMaxLvl })
		end
		
		if (TalentTree:GetHeroCurrentTalentPoints(hero) == 0) then
			for _, talent in pairs(resultTable) do
				if (TalentTree:GetHeroTalentLevel(hero, talent.id) == 0) then
					talent.disabled = true
					talent.lvlup = false
				end
			end
		end
		
		CustomGameEventManager:Send_ServerToPlayer(player, "talent_tree_get_state_from_server", { talents = json.encode(resultTable), points = TalentTree:GetHeroCurrentTalentPoints(hero) })
	end)
end

function TalentTree:OnTalentTreeTalentsRequest(event)
    if (not event or not event.PlayerID) then
        return
    end
    local player = PlayerResource:GetPlayer(event.PlayerID)
    if (not player) then
        return
    end

    local hero = player:GetAssignedHero()
    if (not hero) then
        return
    end

    CustomGameEventManager:Send_ServerToPlayer(player, "talent_tree_get_talents_from_server", {talents = hero.talentsData, tabs = hero.tabs, rows = hero.rows})
end

function TalentTree:OnPlayerReconnect(keys)
    if (not IsServer()) then
        return
    end
    local player = EntIndexToHScript(keys.PlayerID)
    if (not player) then
        return
    end
    local hero = player:GetAssignedHero()
    if (not hero) then
        return
    end

    CustomGameEventManager:Send_ServerToPlayer(player, "talent_tree_get_talents_from_server", {talents = hero.talentsData, tabs = hero.tabs, rows = hero.rows})

    local mod = hero:FindModifierByName("gold_next_level")
    if mod then mod:GetNextGoldState() end
end

TalentTree:Init()

-- ListenToGameEvent("npc_spawned", function(keys)
--     if (not IsServer()) then
--         return
--     end
--     local unit = EntIndexToHScript(keys.entindex)
--     if (TalentTree:IsHeroHaveTalentTree(unit) == false and unit.IsRealHero and unit:IsRealHero()) then
--         TalentTree:SetupForHero(unit)
--     end
-- end, nil)