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

		if level == 7 then
			local ultimate = caster:FindAbilityByName(self.skills[7])
			if ultimate then ultimate:UpgradeAbility(true) end
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

		if level >= 12 then points = points + 1 end
		if level >= 20 then points = points + 1 end

		for i = 1, 6, 1 do
			local skill = caster:FindAbilityByName(self.skills[i])
			if skill then
				if skill:IsTrained() then points = points - 1 end
			end
		end

		caster:SetAbilityPoints(points + pts)

		for i = 1, 6, 1 do
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
		local caster = self:GetCaster()
		local unit_name = caster:GetUnitName()
		if unit_name == "npc_dota_hero_shadow_shaman" then self.hero_name = "dasdingo" end
		if unit_name == "npc_dota_hero_riki" then self.hero_name = "icebreaker" end
		if unit_name == "npc_dota_hero_drow_ranger" then self.hero_name = "genuine" end
		if unit_name == "npc_dota_hero_dawnbreaker" then self.hero_name = "striker" end
	end
	
	function base_hero:ResetRanksData()
		self.slot_keys = {[1] = "slot_1", [2] = "slot_2", [3] = "slot_3", [4] = "slot_4", [5] = "slot_5", [6] = "slot_6"}
		
		local rank = {
			[0] = false, [11] = false, [12] = false, [21] = false, [22] = false, [31] = false, [32] = false, [41] = false, [42] = false		
		}
		
		self.ranks = {
			[0] = {
				[0] = false, [11] = false, [12] = false, [21] = false, [22] = false, [31] = false, [32] = false, [41] = false, [42] = false		
			},
			[1] = {
				[0] = false, [11] = false, [12] = false, [21] = false, [22] = false, [31] = false, [32] = false, [41] = false, [42] = false		
			},
			[2] = {
				[0] = false, [11] = false, [12] = false, [21] = false, [22] = false, [31] = false, [32] = false, [41] = false, [42] = false		
			},
			[3] = {
				[0] = false, [11] = false, [12] = false, [21] = false, [22] = false, [31] = false, [32] = false, [41] = false, [42] = false		
			},
			[4] = {
				[0] = false, [11] = false, [12] = false, [21] = false, [22] = false, [31] = false, [32] = false, [41] = false, [42] = false		
			},
			[5] = {
				[0] = false, [11] = false, [12] = false, [21] = false, [22] = false, [31] = false, [32] = false, [41] = false, [42] = false		
			},
			[6] = {
				[0] = false, [11] = false, [12] = false, [21] = false, [22] = false, [31] = false, [32] = false, [41] = false, [42] = false		
			},
			[7] = {
				[0] = false, [11] = false, [12] = false, [21] = false, [22] = false, [31] = false, [32] = false, [41] = false, [42] = false		
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

		if IsInToolsMode() then
			self:AddGold(9999)
		else
			self:AddGold(self:GetSpecialValueFor("starting_gold"))
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
				for i = 0, 7, 1 do
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

	function base_hero:GetTotalTalents(level)
		local total = 0
		if self.talentsData then
			for talentId,talent in pairs(self.talentsData) do
				if (self:GetHeroTalentLevel(talentId) < self:GetTalentMaxLevel(talentId)) then
					if self:GetTalentRankLevel(talentId) == level and talent.Ability ~= "empty" then
						local ability = self:GetCaster():FindAbilityByName(talent.Tab)
						if ability then
							if ability:IsTrained() then
								total = total + 1
							end
						end
					end
				end
			end
		end

		return total
	end

	function base_hero:IsHeroCanLevelUpTalent(talentId)
		if (not self.talentsData[talentId]) then return false end
		local level = self:GetTalentRankLevel(talentId)
		local points_level = self:GetHeroRankLevel()
		local left = self.max_level - points_level - level

		if left < 5 and (self:GetTotalTalents(left) == 0 or (self:GetTotalTalents(left) == 1 and level == left)) then
			if left == 1 then return false end
			if left == 2 then
				if self:GetTotalTalents(1) < 2 then return false end
			end
			if left == 3 then
				if (self:GetTotalTalents(2) == 0 or self:GetTotalTalents(1) == 0)
				and self:GetTotalTalents(1) < 3 then return false end
			end
			if left == 4 then
				if (self:GetTotalTalents(3) == 0 or self:GetTotalTalents(1) == 0)
				and (self:GetTotalTalents(2) == 0 or self:GetTotalTalents(1) < 2)
				and self:GetTotalTalents(2) < 2
				and self:GetTotalTalents(1) < 4 then return false end
			end
		end

		-- Icebreaker 2.41 requires rank level 14
		if self.talentsData[talentId].Ability == "icebreaker_2__puff_rank_41" then
			local puff = self:GetCaster():FindAbilityByName("icebreaker_2__puff")
			if puff == nil then return false end
			if puff:IsTrained() == false then return false end
			if puff:GetSpecialValueFor("rank") < 14 then return false end
		end

		-- Icebreaker 4.11 requires skill 3
		if self.talentsData[talentId].Ability == "icebreaker_4__mirror_rank_11"
		and (not self.ranks[3][0]) then
			return false
		end

		-- Icebreaker 4.21 requires skill 5
		if self.talentsData[talentId].Ability == "icebreaker_4__mirror_rank_21"
		and (not self.ranks[5][0]) then
			return false
		end

		-- Icebreaker 4.31 requires skill 2
		if self.talentsData[talentId].Ability == "icebreaker_4__mirror_rank_31"
		and (not self.ranks[2][0]) then
			return false
		end

		-- Icebreaker 4.41 requires skill 6
		if self.talentsData[talentId].Ability == "icebreaker_4__mirror_rank_41"
		and (not self.ranks[6][0]) then
			return false
		end


		-- Icebreaker 5.31 requires ultimate
		if self.talentsData[talentId].Ability == "icebreaker_5__wave_rank_31"
		and (not self.ranks[7][0]) then
			return false
		end

		-- Ancient 1.11 requires skill 4
		if self.talentsData[talentId].Ability == "ancient_1__berserk_rank_11"
		and (not self.ranks[4][0]) then
			return false
		end

		-- Ancient 2.31 requires skill 1
		if self.talentsData[talentId].Ability == "ancient_2__leap_rank_31"
		and (not self.ranks[1][0]) then
			return false
		end

		-- Ancient 4.31 requires skill 1
		if self.talentsData[talentId].Ability == "ancient_u__final_rank_31"
		and (not self.ranks[1][0]) then
			return false
		end

		-- Bocuse 4.31 requires skill 1
		if self.talentsData[talentId].Ability == "bocuse_u__mise_rank_31"
		and (not self.ranks[1][0]) then
			return false
		end

		-- Bocuse 4.42 requires rank level 21
		if self.talentsData[talentId].Ability == "bocuse_u__mise_rank_42" then
			local mise = self:GetCaster():FindAbilityByName("bocuse_u__mise")
			if mise == nil then return false end
			if mise:IsTrained() == false then return false end
			if mise:GetSpecialValueFor("rank") < 21 then return false end
		end

		for i = 1, 7, 1 do
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