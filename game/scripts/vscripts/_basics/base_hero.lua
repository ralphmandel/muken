base_hero = class ({})
LinkLuaModifier("base_hero_mod", "_basics/base_hero_mod", LUA_MODIFIER_MOTION_NONE)
require("internal/talent_tree")

-- ABILITY FUNCTIONS
	function base_hero:Spawn()
		if self:IsTrained() == false then self:UpgradeAbility(true) end
	end

	function base_hero:OnUpgrade()
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end

		if self:GetLevel() == 1 then
			self:ResetRanksData()

			Timers:CreateTimer(0.2, function()
				caster:RemoveAbilityByHandle(caster:FindAbilityByName("ability_capture"))
				caster:RemoveAbilityByHandle(caster:FindAbilityByName("abyssal_underlord_portal_warp"))
			end)
		end
	end

	function base_hero:OnHeroLevelUp()
		local caster = self:GetCaster()
		local level = caster:GetLevel()
		if caster:IsIllusion() then return end

		if level == 8 then
			local ultimate = caster:FindAbilityByName(self.skills[6])
			if ultimate then
				if ultimate:IsTrained() == false then
					ultimate:UpgradeAbility(true)
				end
			end
		end

		if level == 14 then
			self:CheckAbilityPoints(1)
		end
	end

	function base_hero:GetIntrinsicModifierName()
		return "base_hero_mod"
	end

-- ABILITY SETTINGS

	function base_hero:OnAbilityUpgrade(ability)
		if ability:GetCaster() == self:GetCaster() then self:CheckAbilityPoints(-1) end
	end

	function base_hero:CheckAbilityPoints(points)
		local caster = self:GetCaster()

		if self.skill_points == nil then
			self.skill_points = 3
			if self.hero_name == "flea" then self.skill_points = 2 end
			if self.hero_name == "striker" then self.skill_points = 2 end
			if self.hero_name == "bloodstained" then self.skill_points = 1 end
			if self.hero_name == "icebreaker" then self.skill_points = 2 end
			if self.hero_name == "genuine" then self.skill_points = 2 end
		end

		self.skill_points = self.skill_points + points

		caster:SetAbilityPoints(self.skill_points)

		for i = 1, 5, 1 do
			local skill = caster:FindAbilityByName(self.skills[i])
			if skill then
				if skill:IsTrained() == false then
					skill:SetHidden(self.skill_points < 1)
				end
			end
		end
	end

-- LOAD DATA
	function base_hero:LoadHeroesData()
		local heroes_name_data = LoadKeyValues("scripts/npc/heroes_name.kv")
		local heroes_team_data = LoadKeyValues("scripts/npc/heroes_team.kv")
		if heroes_name_data == nil then return end
		if heroes_team_data == nil then return end

		for name, id_name in pairs(heroes_name_data) do
			if self:GetCaster():GetUnitName() == id_name then
				self.hero_name = name
			end
		end

    for team, hero_list in pairs(heroes_team_data) do
      for _,id_name in pairs(hero_list) do
        if self:GetCaster():GetUnitName() == id_name then
          self.hero_team = team
        end      
      end
		end
	end
	
	function base_hero:ResetRanksData()
		self.slot_keys = {[1] = "slot_1", [2] = "slot_2", [3] = "slot_3", [4] = "slot_4", [5] = "slot_5", [6] = "slot_6"}
		
		local state_skills = false
		local state_ranks = false

		if IsInToolsMode() then
			-- if self:GetCaster():GetUnitName() == "npc_dota_hero_dawnbreaker" then
			-- state_ranks = true
			-- end
		end

		self.skills = {}
		self.talentsData = {}
		self.tabs = {}
		self.rows = {}
		self.talents = {}
		self.talents.level = {}
		self.talents.abilities = {}
		self.talents.blocked = {}
    self.talents.rank_block = {[1] = 0, [2] = 0, [3] = 0, [4] = 0}
		self.talents.currentPoints = 0
		self.extras_unlocked = 0

		-- RANK LEVEL
		self.current_points = 0
		self.max_level = self:GetSpecialValueFor("max_level")

		-- GOLD INDICATOR
		self.gold_left = self:GetSpecialValueFor("gold_init")
		self.gold_init = self:GetSpecialValueFor("gold_init")
		self.gold_mult = self:GetSpecialValueFor("gold_mult")

		if self.hero_name ~= nil and self.hero_team ~= nil then
			self:LoadSkills()
			self:LoadRanks()
			self:UpdatePanoramaPanels()
		end

		if GetMapName() == "arena_temple_sm" then
			self:AddGold(self:GetSpecialValueFor("starting_gold"))
		end

		if GetMapName() == "muken_arena_turbo" then
			self:AddGold(99999)
		end
	end

	function base_hero:LoadSkills()
		local skills_data = LoadKeyValues("scripts/vscripts/heroes/"..self.hero_team.."/"..self.hero_name.."/"..self.hero_name.."-skills.txt")
		if skills_data ~= nil then
			for skill, skill_name in pairs(skills_data) do
				self.skills[tonumber(skill)] = skill_name
			end
		end
	end

  function base_hero:RandomizeTalentHidden(talent_hidden)
    local tiers_available = {}
    local count = 1

    for i = 1, 4, 1 do
      if talent_hidden.tier ~= i then
        tiers_available[count] = i
        count = count + 1
      end
    end
    
    local tier = tiers_available[RandomInt(1, #tiers_available)]
    local path = RandomInt(1, 2)

    return {tier = tier, path = path}
  end

	function base_hero:LoadRanks()
		local abilitiesData = LoadKeyValues("scripts/vscripts/heroes/"..self.hero_team.."/"..self.hero_name.."/"..self.hero_name..".txt")
		local ranks_data = LoadKeyValues("scripts/vscripts/heroes/"..self.hero_team.."/"..self.hero_name.."/"..self.hero_name.."-ranks.txt")
		if ranks_data == nil then return end

		for _,unit in pairs(ranks_data) do
			if not unit["min_level"] then
				for i = 1, 6, 1 do
          local talents_hidden = {}
          talents_hidden[1] = self:RandomizeTalentHidden({tier = 0, path = 0})
          talents_hidden[2] = self:RandomizeTalentHidden(talents_hidden[1])
					for tabName, tabData in pairs(unit) do
						if tabName == self.skills[i] then
							table.insert(self.tabs, tabName) -- self.tabs == abilities name
							for nlvl, talents in pairs(tabData) do
								table.insert(self.rows, tonumber(nlvl)) -- self.rows == ranks level
                for x = 1, 2, 1 do
                  for path, talent in pairs(talents) do
                    if tonumber(path) == x then
                      local hidden = false
                      for _,talent_hidden in pairs(talents_hidden) do
                        if tonumber(nlvl) == talent_hidden.tier
                        and tonumber(path) == talent_hidden.path then
                          --hidden = true
                        end
                      end

                      local talentData = {
                        Ability = talent, -- rank name
                        Tab = tabName, -- ability name
                        RankLevel = tonumber(nlvl), -- rank level
                        Path = tonumber(path), -- rank path
                        Hidden = hidden
                      }
                      table.insert(self.talentsData, talentData)
                    end
                  end                 
                end
							end
						end 
					end
				end
			end
		end
		
		local loclenght = 1
		local locarr = {}
		table.sort(self.rows)
		for i = 1, #self.rows do
			if locarr[self.rows[i]] == nil then
				locarr[self.rows[i]] = loclenght
				loclenght = loclenght + 1
			end
		end

		self.rows = locarr
		for i = 1, #self.talentsData do
			self.talents.level[i] = 0
		end
	end

-- UPDATE DATA
	function base_hero:UpdatePanoramaPanels()
		local player = self:GetCaster():GetPlayerOwner()
		if (not player) then return end

		CustomGameEventManager:Send_ServerToPlayer(player, "talent_tree_get_talents_from_server", {
			talents = self.talentsData,
			tabs = self.tabs,
			rows = self.rows
		})
	end

	function base_hero:UpdatePanoramaState()
		local player = self:GetCaster():GetPlayerOwner()
		if (not player) then return end

		Timers:CreateTimer(0, function()
			if not self.talents then return 1.0 end

			local resultTable = {}
			for i = 1, #self.talentsData do
				local talentLvl = self:GetHeroTalentLevel(i)
				local talentMaxLvl = self:GetTalentMaxLevel(i)
				local isDisabled = self:IsHeroCanLevelUpTalent(i) == false
				local isUpgraded = false

				if (talentLvl == talentMaxLvl) then
					isDisabled = false
					isUpgraded = true
				end

				table.insert(resultTable, {
					id = i, disabled = isDisabled, upgraded = isUpgraded,
					level = talentLvl, maxlevel = talentMaxLvl, hidden = self.talentsData[i].Hidden
				})
			end
			
			if self.current_points == 0 then
				for _, talent in pairs(resultTable) do
					if (self:GetHeroTalentLevel(talent.id) == 0) then
						talent.disabled = true
						talent.lvlup = false
					end
				end
			end
			
			CustomGameEventManager:Send_ServerToPlayer(player, "talent_tree_get_state_from_server", {
				talents = json.encode(resultTable),
				points = self.current_points
			})
		end)
	end

	function base_hero:UpdatePanoramaGold()
		local player = self:GetCaster():GetPlayerOwner()
		if (not player) then return end

		CustomGameEventManager:Send_ServerToPlayer(player, "next_up_from_server", {
			points = self.gold_left
		})
	end

	function base_hero:UpgradeRank(skill, id, level, talentId)
		local caster = self:GetCaster()
		local ability = nil
		
		ability = caster:FindAbilityByName(self.skills[skill])
		if not ability then return end
		if not ability:IsTrained() then return end

		ability:SetLevel(ability:GetLevel() + level)
		caster:AddExperience(level * 10, 0, false, false)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_SHARD, caster, level, caster)

    self.talents.rank_block[level] = self.talents.rank_block[level] + 1

    for i, talent in pairs(self.talentsData) do
      if self.talentsData[i].Tab == self.skills[skill] then
        if self.talentsData[i].RankLevel == level then
          if self.talentsData[i].Ability ~= self.talentsData[talentId].Ability then
            self.talents.blocked[self.talentsData[i].Ability] = true
          end
        end
      end
    end
	end

	function base_hero:AddGold(amount)
		self.gold_left = self.gold_left - amount
		self:CalculateGold()
	end

	function base_hero:CalculateGold()
		local total_points = self:GetHeroRankLevel() + self.current_points
		if total_points >= self.max_level then
			self.gold_left = 0
		else
			if self.gold_left < 0 then
				self.gold_left = self.gold_left + (self.gold_init + (self.gold_mult * (total_points + 1)))
				self:AddTalentPointsToHero(1)
				self:CalculateGold()
				return
			end
		end

		self:UpdatePanoramaGold()
	end

-- RANK SYSTEM
	function base_hero:GetColumnTalentPoints(tab)
		local points = 0
		if self.talents then
			for talentId, lvl in pairs(self.talents.level) do
				if self.talentsData[talentId].Tab == tab then
					points = points + lvl
				end
			end
		end
		return points
	end

	function base_hero:AddTalentPointsToHero(points)
		points = tonumber(points)
		if (not points) then return false end
		self.current_points = self.current_points + points

		self:UpdatePanoramaState()
	end

	function base_hero:GetHeroTalentLevel(talentId)
		if (talentId and talentId > 0) then
			return self.talents.level[talentId]
		end
		return 0
	end

	function base_hero:GetTalentMaxLevel(talentId)
		if self.talentsData[talentId] then
			return self.talentsData[talentId].RankLevel
		end
		return -1
	end

	function base_hero:GetTalentRankLevel(talentId)
		return self.talentsData[talentId].RankLevel
	end

	function base_hero:GetHeroRankLevel()
		local rank = 0
		if self.talentsData then
			for talentId, talent in pairs(self.talentsData) do
				rank = rank + self:GetHeroTalentLevel(talentId)
			end
		end

		return rank
	end

	function base_hero:GetTotalTalents(level, flag)
		local total = 0
		if self.talentsData then
			for talentId, talent in pairs(self.talentsData) do
				if flag then
					if self.talentsData[talentId] ~= flag then
						if self:IsTalentAvailable(talentId, level) then
							total = total + 1
						end
					end
				else
					if self:IsTalentAvailable(talentId, level) then
						total = total + 1
					end
				end
			end
		end

		return total
	end

	function base_hero:IsTalentAvailable(talentId, level)
		if self.talentsData[talentId].Ability == "empty" then return false end
		if self:CheckRequirements(talentId, self.talentsData[talentId].Ability) == false then return false end
		if (self:GetHeroTalentLevel(talentId) >= self:GetTalentMaxLevel(talentId)) then return false end
		if level == -1 and self:GetTalentRankLevel(talentId) % 2 == 0 then return false end
		if level > 0 and self:GetTalentRankLevel(talentId) ~= level then return false end
		local ability = self:GetCaster():FindAbilityByName(self.talentsData[talentId].Tab)
		if ability == nil then return false end
		if ability:IsTrained() == false then return false end

		return true
	end

	function base_hero:CheckRequirements(talentId, talentName)
    if self.talentsData[talentId].Hidden == true then return false end
    if self.talents.blocked[self.talentsData[talentId].Ability] then return false end
    if self.talents.rank_block[self.talentsData[talentId].RankLevel] >= 3 then return false end

		-- BLOODSTAINED
			-- Bloodstained 5.31 requires ultimate
			if talentName == "bloodstained_5__tear_rank_31"
			and self:GetCaster():FindAbilityByName("bloodstained_u__seal"):IsTrained() == false then
				return false
			end

		-- BALDUR
			-- Baldur 5.41 requires skill 3
			if talentName == "bald_5__spike_rank_41"
			and self:GetCaster():FindAbilityByName("bald_3__inner"):IsTrained() == false then
				return false
			end

		-- ICEBREAKER
			-- Icebreaker 5.41 requires ultimate
			if talentName == "icebreaker_5__shivas_rank_41"
			and self:GetCaster():FindAbilityByName("icebreaker_5__shivas"):IsTrained() == false then
				return false
			end

		-- STRIKER
			-- Striker 6.11 requires skill 5 max rank
			if talentName == "striker_u__auto_rank_11"
			and self:GetCaster():FindAbilityByName("striker_5__sof"):GetLevel() < 11 then
				return false
			end

			-- Striker 6.12 requires skill 3 max rank
			if talentName == "striker_u__auto_rank_12"
			and self:GetCaster():FindAbilityByName("striker_3__portal"):GetLevel() < 11 then
				return false
			end

			-- Striker 6.21 requires skill 2 max rank
			if talentName == "striker_u__auto_rank_21"
			and self:GetCaster():FindAbilityByName("striker_2__shield"):GetLevel() < 11 then
				return false
			end

			-- Striker 6.22 requires skill 4 max rank
			if talentName == "striker_u__auto_rank_22"
			and self:GetCaster():FindAbilityByName("striker_4__hammer"):GetLevel() < 11 then
				return false
			end

		return true
	end

	function base_hero:CalculateLeft(talentId)
		local level = self:GetTalentRankLevel(talentId)
		local points_level = self:GetHeroRankLevel()
		local left = self.max_level - level - points_level
		local flag = self.talentsData[talentId]

		if left == 0 then return true end
		if self:GetTotalTalents(left, flag) >= 1 then return true end
		if self:GetTotalTalents(1, flag) >= left then return true end
		if (left % 2 == 1) and (self:GetTotalTalents(-1, flag) == 0) then return false end

		local i = 2
		while left > i do
			if (self:GetTotalTalents(i, flag) >= 1 and self:GetTotalTalents(1, flag) >= left - i) then return true end			
			i = i + 1
		end

		if left == 4 then
			if self:GetTotalTalents(2, flag) >= 2 then return true end
		end

		if left == 5 then
			if self:GetTotalTalents(3, flag) >= 1 and self:GetTotalTalents(2, flag) >= 1 then return true end
			if self:GetTotalTalents(2, flag) >= 2 and self:GetTotalTalents(1, flag) >= 1 then return true end
		end

		if left == 6 then
			if self:GetTotalTalents(4, flag) >= 1 and self:GetTotalTalents(2, flag) >= 1 then return true end

			if self:GetTotalTalents(3, flag) >= 2 then return true end
			if self:GetTotalTalents(3, flag) >= 1 and self:GetTotalTalents(2, flag) >= 1 and self:GetTotalTalents(1, flag) >= 1 then return true end

			if self:GetTotalTalents(2, flag) >= 3 then return true end
			if self:GetTotalTalents(2, flag) >= 2 and self:GetTotalTalents(1, flag) >= 2 then return true end
		end

		if left == 7 then
			if self:GetTotalTalents(4, flag) >= 1 and self:GetTotalTalents(3, flag) >= 1 then return true end
			if self:GetTotalTalents(4, flag) >= 1 and self:GetTotalTalents(2, flag) >= 1 and self:GetTotalTalents(1, flag) >= 1 then return true end
			
			if self:GetTotalTalents(3, flag) >= 2 and self:GetTotalTalents(1, flag) >= 1 then return true end
			if self:GetTotalTalents(3, flag) >= 1 and self:GetTotalTalents(2, flag) >= 2 then return true end
			if self:GetTotalTalents(3, flag) >= 1 and self:GetTotalTalents(2, flag) >= 1 and self:GetTotalTalents(1, flag) >= 2 then return true end

			if self:GetTotalTalents(2, flag) >= 3 and self:GetTotalTalents(1, flag) >= 1 then return true end
			if self:GetTotalTalents(2, flag) >= 2 and self:GetTotalTalents(1, flag) >= 3 then return true end
		end

		if left == 8 then
			if self:GetTotalTalents(4, flag) >= 2 then return true end
			if self:GetTotalTalents(4, flag) >= 1 and self:GetTotalTalents(3, flag) >= 1 and self:GetTotalTalents(1, flag) >= 1 then return true end
			if self:GetTotalTalents(4, flag) >= 1 and self:GetTotalTalents(2, flag) >= 2 then return true end
			if self:GetTotalTalents(4, flag) >= 1 and self:GetTotalTalents(2, flag) >= 1 and self:GetTotalTalents(1, flag) >= 2 then return true end

			if self:GetTotalTalents(3, flag) >= 2 and self:GetTotalTalents(2, flag) >= 1 then return true end
			if self:GetTotalTalents(3, flag) >= 2 and self:GetTotalTalents(1, flag) >= 2 then return true end

			if self:GetTotalTalents(3, flag) >= 1 and self:GetTotalTalents(2, flag) >= 2 and self:GetTotalTalents(1, flag) >= 1 then return true end
			if self:GetTotalTalents(3, flag) >= 1 and self:GetTotalTalents(2, flag) >= 1 and self:GetTotalTalents(1, flag) >= 3 then return true end

			if self:GetTotalTalents(2, flag) >= 4 then return true end
			if self:GetTotalTalents(2, flag) >= 3 and self:GetTotalTalents(1, flag) >= 2 then return true end
			if self:GetTotalTalents(2, flag) >= 2 and self:GetTotalTalents(1, flag) >= 4 then return true end
		end

		if left > 8 then return true end

		return false
	end

	function base_hero:IsHeroCanLevelUpTalent(talentId)
		if (not self.talentsData[talentId]) then return false end
		if self.talentsData[talentId].Ability == "empty" then return false end
		if self:CheckRequirements(talentId, self.talentsData[talentId].Ability) == false then return false end

		for i = 1, 6, 1 do
			if self.talentsData[talentId].Tab == self.skills[i]
			and self:GetCaster():FindAbilityByName(self.skills[i]):IsTrained() == false then
				return false
			end
		end

		if (self:GetHeroTalentLevel(talentId) >= self:GetTalentMaxLevel(talentId)) then
			return false
		end

		if self.current_points < self:GetTalentMaxLevel(talentId) then
			return false
		end

		if self:CalculateLeft(talentId) == false then
			return false
		end

		return true
	end

	function base_hero:SetHeroTalentLevel(talentId, level)
		level = tonumber(level)
		if (self.talents and talentId > 0 and level and level > -1) then
			self.talents.level[talentId] = level
			-- remove
			if (level == 0) then
				if (self.talents.abilities[talentId]) then
					self.talents.abilities[talentId]:GetCaster():RemoveAbilityByHandle(self.talents.abilities[talentId])
					self.talents.abilities[talentId] = nil
				end
			-- level up
			else
				if (not self.talents.abilities[talentId]) then
					local ability = self:GetCaster():FindAbilityByName(self.talentsData[talentId].Ability)
					if ability == nil then
						self.talents.abilities[talentId] = self:GetCaster():AddAbility(self.talentsData[talentId].Ability)
						self.talents.abilities[talentId]:UpgradeAbility(true)
					else
						--ability:UpgradeAbility(true)
						self.talents.abilities[talentId] = ability
						self.talents.abilities[talentId]:UpgradeAbility(true)
					end

					local skill = self.talents.abilities[talentId]:GetSpecialValueFor("skill")
					local id = self.talents.abilities[talentId]:GetSpecialValueFor("id")
					local permanent = self.talents.abilities[talentId]:GetSpecialValueFor("permanent")
					self:UpgradeRank(skill, id, level, talentId)

					if permanent == 0 then
						--self:GetCaster():RemoveAbilityByHandle(self.talents.abilities[talentId])
						--self.talents.abilities[talentId] = nil
					end
				elseif(self.talents.abilities[talentId]) then
					local skill = self.talents.abilities[talentId]:GetSpecialValueFor("skill")
					local id = self.talents.abilities[talentId]:GetSpecialValueFor("id")
					self:UpgradeRank(skill, id, level, talentId)

					self.talents.abilities[talentId]:SetLevel(level)
				end
			end
			
			self:UpdatePanoramaState()
		end
	end