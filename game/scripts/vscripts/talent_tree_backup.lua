
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
    elseif hero:GetUnitName() == "npc_dota_hero_pudge" then
        self.abilitiesData = LoadKeyValues("scripts/vscripts/heroes/bocuse/bocuse.txt")
        data = LoadKeyValues("scripts/vscripts/heroes/bocuse/bocuse-ranks.txt")
        hero.att = "base_ranks"
    elseif hero:GetUnitName() == "npc_dota_hero_shadow_shaman" then
        self.abilitiesData = LoadKeyValues("scripts/vscripts/heroes/dasdingo/dasdingo.txt")
        data = LoadKeyValues("scripts/vscripts/heroes/dasdingo/dasdingo-ranks.txt")
        hero.att = "dasdingo__attributes"
    elseif hero:GetUnitName() == "npc_dota_hero_furion" then
        self.abilitiesData = LoadKeyValues("scripts/vscripts/heroes/druid/druid.txt")
        data = LoadKeyValues("scripts/vscripts/heroes/druid/druid-ranks.txt")
        hero.att = "druid__attributes"
    elseif hero:GetUnitName() == "npc_dota_hero_elder_titan" then
        self.abilitiesData = LoadKeyValues("scripts/vscripts/heroes/ancient/ancient.txt")
        data = LoadKeyValues("scripts/vscripts/heroes/ancient/ancient-ranks.txt")
        hero.att = "ancient__attributes"
    elseif hero:GetUnitName() == "npc_dota_hero_drow_ranger" then
        self.abilitiesData = LoadKeyValues("scripts/vscripts/heroes/genuine/genuine.txt")
        data = LoadKeyValues("scripts/vscripts/heroes/genuine/genuine-ranks.txt")
        hero.att = "genuine__attributes"
    elseif hero:GetUnitName() == "npc_dota_hero_spectre" then
        self.abilitiesData = LoadKeyValues("scripts/vscripts/heroes/shadow/shadow.txt")
        data = LoadKeyValues("scripts/vscripts/heroes/shadow/shadow-ranks.txt")
        hero.att = "shadow__attributes"
    elseif hero:GetUnitName() == "npc_dota_hero_queenofpain" then
        self.abilitiesData = LoadKeyValues("scripts/vscripts/heroes/succubus/succubus.txt")
        data = LoadKeyValues("scripts/vscripts/heroes/succubus/succubus-ranks.txt")
        hero.att = "succubus__attributes"
    elseif hero:GetUnitName() == "npc_dota_hero_phantom_assassin" then
        self.abilitiesData = LoadKeyValues("scripts/vscripts/heroes/gladiator/gladiator.txt")
        data = LoadKeyValues("scripts/vscripts/heroes/gladiator/gladiator-ranks.txt")
        hero.att = "gladiator__attributes"
    end

    hero.talentsData = {}
    hero.tabs = {}
    hero.rows = {}
	
	for _,unit in pairs(data) do
		if not unit["min_level"] then
            local att = hero:FindAbilityByName(hero.att)
            if (not att) then return false end
            for i = 0, 5, 1 do
                for tabName, tabData in pairs(unit) do
                    local isTab = false
                    if i == 5 then
                        if tabName == "extras" then
                            isTab = true
                        end
                    else
                        if att.skills[i] then
                            if tabName == att.skills[i] then
                                isTab = true
                            end
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

    local level = TalentTree:GetTalentRankLevel(hero, talentId)
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

    -- Ancient 1.11 requires skill 4
    if hero.talentsData[talentId].Ability == "ancient_1__berserk_rank_11"
    and (not att.talents[4][0]) then
        return false
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

    -- Bocuse 4.42 requires rank level 21
    if hero.talentsData[talentId].Ability == "bocuse_u__mise_rank_42" then
        local mise = hero:FindAbilityByName("bocuse_u__mise")
        if mise == nil then return false end
        if mise:IsTrained() == false then return false end
        if mise:GetSpecialValueFor("rank") < 21 then return false end
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
                if hero:GetLevel() < 8 then
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
            if (TalentTree:GetHeroTalentLevel(hero, talentId) < TalentTree:GetTalentMaxLevel(hero, talentId)) then
                if TalentTree:GetTalentRankLevel(hero, talentId) == level
                and talent.Ability ~= "empty" then
                    total = total + 1
                end
            end
        end
    end

    return total
end

function TalentTree:GetTalentRankLevel(hero, talentId)
    local talent_level = hero.talentsData[talentId].NeedLevel + 1
    if hero.talentsData[talentId].Tab == "extras" then talent_level = 5 end

    return talent_level
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