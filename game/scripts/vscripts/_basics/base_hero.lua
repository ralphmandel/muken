base_hero = class ({})
LinkLuaModifier("base_hero_mod", "_basics/base_hero_mod", LUA_MODIFIER_MOTION_NONE)
require("talent_tree")

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
				self:CheckSkills(0, nil)
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

		self:CheckSkills(0, nil)
	end

	function base_hero:GetIntrinsicModifierName()
		return "base_hero_mod"
	end

-- ABILITY SETTINGS

	function base_hero:SetHotkeys(ability, bUltimate)
		if not self.slot_index then self.slot_index = 1 end

		local caster = self:GetCaster()
		local slot = self.slot_keys[self.slot_index]

		if bUltimate then
			slot = self.slot_keys[6]
		else
			self.slot_index = self.slot_index + 1
		end

		caster:SwapAbilities(ability:GetAbilityName(), slot, true, false)
	end

	function base_hero:CheckSkills(pts, ability)
		if ability then self:SetHotkeys(ability, false) end

		local caster = self:GetCaster()
		local level = caster:GetLevel()
		local points = 3

		--if level >= 7 then points = points + 1 end
		if level >= 12 then points = points + 1 end

		for i = 1, 5, 1 do
			local skill = caster:FindAbilityByName(self.skills[i])
			if skill then
				if skill:IsTrained() then points = points - 1 end
			end
		end

		caster:SetAbilityPoints(points + pts)

		for i = 1, 5, 1 do
			local skill = caster:FindAbilityByName(self.skills[i])
			if skill then
				if skill:IsTrained() == false then
					skill:SetHidden(points < 1)
				end
			end
		end
	end

-- LOAD DATA
	function base_hero:LoadHeroNames()
		local heroes_name_data = LoadKeyValues("scripts/npc/heroes_name.kv")
		if heroes_name_data == nil then return end
		for name, id_name in pairs(heroes_name_data) do
			if self:GetCaster():GetUnitName() == id_name then
				self.hero_name = name
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
		
		self.ranks = {
			[0] = {
				[0] = state_skills, [11] = state_ranks, [12] = state_ranks, [21] = state_ranks, [22] = state_ranks, [31] = state_ranks, [32] = state_ranks, [41] = state_ranks, [42] = state_ranks		
			},
			[1] = {
				[0] = state_skills, [11] = state_ranks, [12] = state_ranks, [21] = state_ranks, [22] = state_ranks, [31] = state_ranks, [32] = state_ranks, [41] = state_ranks, [42] = state_ranks		
			},
			[2] = {
				[0] = state_skills, [11] = state_ranks, [12] = state_ranks, [21] = state_ranks, [22] = state_ranks, [31] = state_ranks, [32] = state_ranks, [41] = state_ranks, [42] = state_ranks		
			},
			[3] = {
				[0] = state_skills, [11] = state_ranks, [12] = state_ranks, [21] = state_ranks, [22] = state_ranks, [31] = state_ranks, [32] = state_ranks, [41] = state_ranks, [42] = state_ranks		
			},
			[4] = {
				[0] = state_skills, [11] = state_ranks, [12] = state_ranks, [21] = state_ranks, [22] = state_ranks, [31] = state_ranks, [32] = state_ranks, [41] = state_ranks, [42] = state_ranks		
			},
			[5] = {
				[0] = state_skills, [11] = state_ranks, [12] = state_ranks, [21] = state_ranks, [22] = state_ranks, [31] = state_ranks, [32] = state_ranks, [41] = state_ranks, [42] = state_ranks		
			},
			[6] = {
				[0] = state_skills, [11] = state_ranks, [12] = state_ranks, [21] = state_ranks, [22] = state_ranks, [31] = state_ranks, [32] = state_ranks, [41] = state_ranks, [42] = state_ranks		
			}
		}

		self.skills = {}
		self.talentsData = {}
		self.tabs = {}
		self.rows = {}
		self.talents = {}
		self.talents.level = {}
		self.talents.abilities = {}
		self.talents.currentPoints = 0
		self.extras_unlocked = 0

		-- RANK LEVEL
		self.current_points = 0
		self.max_level = self:GetSpecialValueFor("max_level")

		-- GOLD INDICATOR
		self.gold_left = self:GetSpecialValueFor("gold_init")
		self.gold_init = self:GetSpecialValueFor("gold_init")
		self.gold_mult = self:GetSpecialValueFor("gold_mult")

		if self.hero_name ~= nil then
			self:LoadSkills()
			self:LoadRanks()
			self:UpdatePanoramaPanels()
		end

		if GetMapName() == "arena_temple_sm" then
			self:AddGold(self:GetSpecialValueFor("starting_gold"))
		end

		if GetMapName() == "arena_turbo" then
			self:AddGold(99999)
		end
	end

	function base_hero:LoadSkills()
		local skills_data = LoadKeyValues("scripts/vscripts/heroes/"..self.hero_name.."/"..self.hero_name.."-skills.txt")
		if skills_data ~= nil then
			for skill, skill_name in pairs(skills_data) do
				self.skills[tonumber(skill)] = skill_name
			end
		end
	end

	function base_hero:LoadRanks()
		local abilitiesData = LoadKeyValues("scripts/vscripts/heroes/"..self.hero_name.."/"..self.hero_name..".txt")
		local ranks_data = LoadKeyValues("scripts/vscripts/heroes/"..self.hero_name.."/"..self.hero_name.."-ranks.txt")
		if ranks_data == nil then return end

		for _,unit in pairs(ranks_data) do
			if not unit["min_level"] then
				for i = 0, 6, 1 do
					for tabName, tabData in pairs(unit) do
						local isTab = false
						if self.skills[i] then
							if tabName == self.skills[i] then
								isTab = true
							end
						end

						if isTab == true then
							table.insert(self.tabs, tabName)
							for nlvl, talents in pairs(tabData) do
								table.insert(self.rows, tonumber(nlvl))
								for _, talent in pairs(talents) do
									local talentData = {
										Ability = talent,
										Tab = tabName,
										NeedLevel = tonumber(nlvl)
									}
									
									if abilitiesData[talent] then
										talentData.MaxLevel = abilitiesData[talent]["MaxLevel"] or 1
									else
										talentData.MaxLevel = 1
									end
									table.insert(self.talentsData, talentData)
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
					level = talentLvl, maxlevel = talentMaxLvl
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

	function base_hero:UpgradeRank(skill, id, level)
		local caster = self:GetCaster()
		local ability = nil
		
		self.ranks[skill][id] = true
		ability = caster:FindAbilityByName(self.skills[skill])
		if not ability then return end
		if not ability:IsTrained() then return end

		ability:SetLevel(ability:GetLevel() + level)
		caster:AddExperience(level * 10, 0, false, false)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_SHARD, caster, level, caster)
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
			return self.talentsData[talentId].MaxLevel
		end
		return -1
	end

	function base_hero:GetTalentRankLevel(talentId)
		local talent_level = self.talentsData[talentId].NeedLevel + 1
		if self.talentsData[talentId].Tab == "extras" then talent_level = 5 end

		return talent_level
	end

	function base_hero:GetHeroRankLevel()
		local rank = 0
		if self.talentsData then
			for talentId,talent in pairs(self.talentsData) do
				rank = rank + self:GetHeroTalentLevel(talentId)
			end
		end

		return rank
	end

	function base_hero:GetTotalTalents(level, flag)
		local total = 0
		if self.talentsData then
			for talentId,talent in pairs(self.talentsData) do
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
		if self:CheckRequirements(self.talentsData[talentId].Ability) == false then return false end
		if (self:GetHeroTalentLevel(talentId) >= self:GetTalentMaxLevel(talentId)) then return false end
		if level == -1 and self:GetTalentRankLevel(talentId) % 2 == 0 then return false end
		if level > 0 and self:GetTalentRankLevel(talentId) ~= level then return false end
		local ability = self:GetCaster():FindAbilityByName(self.talentsData[talentId].Tab)
		if ability == nil then return end
		if ability:IsTrained() == false then return end

		return true
	end

	function base_hero:CheckRequirements(talentName)
		-- FLEAMAN
			-- Fleaman 1.32 requires skill rank level 16
			if talentName == "flea_1__precision_rank_32" then
				local precision = self:GetCaster():FindAbilityByName("flea_1__precision")
				if precision == nil then return false end
				if precision:IsTrained() == false then return false end
				if precision:GetSpecialValueFor("rank") < 16 then return false end
			end

			-- Fleaman 6.41 requires skill rank level 15
			if talentName == "flea_u__weakness_rank_41" then
				local weakness = self:GetCaster():FindAbilityByName("flea_u__weakness")
				if weakness == nil then return false end
				if weakness:IsTrained() == false then return false end
				if weakness:GetSpecialValueFor("rank") < 15 then return false end
			end

		-- ANCIENT ONE
			-- Ancient 1.41 requires skill rank level 12
			if talentName == "ancient_1__berserk_rank_41" then
				local berserk = self:GetCaster():FindAbilityByName("ancient_1__berserk")
				if berserk == nil then return false end
				if berserk:IsTrained() == false then return false end
				if berserk:GetSpecialValueFor("rank") < 12 then return false end
			end

			-- Ancient 2.31 requires skill 1.21
			if talentName == "ancient_2__leap_rank_31"
			and (not self.ranks[1][21]) then
				return false
			end

			-- Ancient 3.31 requires skill 4
			if talentName == "ancient_3__walk_rank_31"
			and (not self.ranks[4][0]) then
				return false
			end

			-- Ancient Ultimate requires Hero level 8
			if self:GetCaster():GetLevel() < 8 then
				if talentName == "ancient_u__final_rank_12"
				or talentName == "ancient_u__final_rank_21"
				or talentName == "ancient_u__final_rank_41" then
					return false
				end
			end

		-- ICEBREAKER
			-- Icebreaker 2.41 requires skill rank level 14
			if talentName == "icebreaker_2__puff_rank_41" then
				local puff = self:GetCaster():FindAbilityByName("icebreaker_2__puff")
				if puff == nil then return false end
				if puff:IsTrained() == false then return false end
				if puff:GetSpecialValueFor("rank") < 14 then return false end
			end

			-- Icebreaker 4.31 requires skill rank level 10
			if talentName == "icebreaker_4__wave_rank_31" then
				local wave = self:GetCaster():FindAbilityByName("icebreaker_4__wave")
				if wave == nil then return false end
				if wave:IsTrained() == false then return false end
				if wave:GetSpecialValueFor("rank") < 10 then return false end
			end

			-- Icebreaker 5.11 requires skill 3
			if talentName == "icebreaker_5__mirror_rank_11"
			and (not self.ranks[3][0]) then
				return false
			end

			-- Icebreaker 5.21 requires skill 4
			if talentName == "icebreaker_5__mirror_rank_21"
			and (not self.ranks[4][0]) then
				return false
			end

			-- Icebreaker 5.31 requires skill 2
			if talentName == "icebreaker_5__mirror_rank_31"
			and (not self.ranks[2][0]) then
				return false
			end

			-- Icebreaker 5.41 requires ultimate
			if talentName == "icebreaker_5__mirror_rank_41"
			and (not self.ranks[6][0]) then
				return false
			end

		-- GENUINE
			-- Genuine 1.41 requires skill rank level 14
			if talentName == "genuine_1__shooting_rank_41" then
				local shooting = self:GetCaster():FindAbilityByName("genuine_1__shooting")
				if shooting == nil then return false end
				if shooting:IsTrained() == false then return false end
				if shooting:GetSpecialValueFor("rank") < 14 then return false end
			end

		-- BOCUSE
			-- Bocuse 2.41 requires skill rank level 13
			if talentName == "bocuse_2__flask_rank_41" then
				local flask = self:GetCaster():FindAbilityByName("bocuse_2__flask")
				if flask == nil then return false end
				if flask:IsTrained() == false then return false end
				if flask:GetSpecialValueFor("rank") < 13 then return false end
			end

			-- Bocuse 6.21 requires skill 1
			if talentName == "bocuse_u__rage_rank_21"
			and (not self.ranks[1][0]) then
				return false
			end

			-- Bocuse 6.41 requires skill rank level 19
			if talentName == "bocuse_u__rage_rank_41" then
				local rage = self:GetCaster():FindAbilityByName("bocuse_u__rage")
				if rage == nil then return false end
				if rage:IsTrained() == false then return false end
				if rage:GetSpecialValueFor("rank") < 19 then return false end
			end

		-- STRIKER
			-- Striker 2.41 requires skill rank level 12
			if talentName == "striker_2__shield_rank_41" then
				local striker = self:GetCaster():FindAbilityByName("striker_2__shield")
				if striker == nil then return false end
				if striker:IsTrained() == false then return false end
				if striker:GetSpecialValueFor("rank") < 12 then return false end
			end

			-- Striker 3.41 requires skill rank level 12
			if talentName == "striker_3__portal_rank_41" then
				local striker = self:GetCaster():FindAbilityByName("striker_3__portal")
				if striker == nil then return false end
				if striker:IsTrained() == false then return false end
				if striker:GetSpecialValueFor("rank") < 12 then return false end
			end

			-- Striker 4.41 requires skill rank level 12
			if talentName == "striker_4__hammer_rank_41" then
				local striker = self:GetCaster():FindAbilityByName("striker_4__hammer")
				if striker == nil then return false end
				if striker:IsTrained() == false then return false end
				if striker:GetSpecialValueFor("rank") < 12 then return false end
			end

			-- Striker 5.41 requires skill rank level 12
			if talentName == "striker_5__sof_rank_41" then
				local striker = self:GetCaster():FindAbilityByName("striker_5__sof")
				if striker == nil then return false end
				if striker:IsTrained() == false then return false end
				if striker:GetSpecialValueFor("rank") < 12 then return false end
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
		if self:CheckRequirements(self.talentsData[talentId].Ability) == false then return false end

		for i = 1, 6, 1 do
			if self.talentsData[talentId].Tab == self.skills[i]
			and (not self.ranks[i][0]) then
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
					self:UpgradeRank(skill, id, level)

					if permanent == 0 then
						self:GetCaster():RemoveAbilityByHandle(self.talents.abilities[talentId])
						self.talents.abilities[talentId] = nil
					end

				elseif(self.talents.abilities[talentId]) then
					local skill = self.talents.abilities[talentId]:GetSpecialValueFor("skill")
					local id = self.talents.abilities[talentId]:GetSpecialValueFor("id")
					self:UpgradeRank(skill, id, level)

					self.talents.abilities[talentId]:SetLevel(level)
				end
			end
			
			self:UpdatePanoramaState()
		end
	end