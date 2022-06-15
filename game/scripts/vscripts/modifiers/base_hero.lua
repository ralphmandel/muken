base_hero = class ({})
LinkLuaModifier("base_hero_mod", "modifiers/base_hero_mod", LUA_MODIFIER_MOTION_NONE)
require("talent_tree")

-- ABILITY FUNCTIONS
	function base_hero:Spawn()
		if self:IsTrained() == false then self:UpgradeAbility(true) end
	end

	function base_hero:OnUpgrade()
		local caster = self:GetCaster()
		if caster:IsIllusion() then return end

		if self:GetLevel() == 1 then
			caster:SetAbilityPoints(1)
			self:ResetRanksData()
			self.extras_unlocked = 0
		end
	end

	function base_hero:OnHeroLevelUp()
		local caster = self:GetCaster()
		local level = caster:GetLevel()
		if caster:IsIllusion() then return end

		local gain = 0
		if level ~= 1 and level ~= 3 and level ~= 7 then gain = -1 end
		caster:SetAbilityPoints((caster:GetAbilityPoints() + gain))
	end

	function base_hero:GetIntrinsicModifierName()
		return "base_hero_mod"
	end

-- LOAD DATA
	function base_hero:ResetRanksData()
		local caster = self:GetCaster()
		self.hero_name = nil
		if caster:GetUnitName() == "npc_dota_hero_shadow_shaman" then self.hero_name = "dasdingo" end
		if caster:GetUnitName() == "npc_dota_hero_elder_titan" then self.hero_name = "ancient" end
		if caster:GetUnitName() == "npc_dota_hero_pudge" then self.hero_name = "bocuse" end
		if caster:GetUnitName() == "npc_dota_hero_shadow_demon" then self.hero_name = "bloodstained" end
		if caster:GetUnitName() == "npc_dota_hero_riki" then self.hero_name = "icebreaker" end
		if caster:GetUnitName() == "npc_dota_hero_furion" then self.hero_name = "druid" end
		if caster:GetUnitName() == "npc_dota_hero_drow_ranger" then self.hero_name = "genuine" end
		if caster:GetUnitName() == "npc_dota_hero_spectre" then self.hero_name = "shadow" end

		self.talents = {
			[0] = {
				[0] = false, [11] = false, [12] = false, [13] = false, [21] = false, [22] = false,
				[23] = false, [31] = false, [32] = false, [33] = false, [41] = false, [42] = false
			},
			[1] = {
				[0] = false, [11] = false, [12] = false, [13] = false, [21] = false, [22] = false,
				[23] = false, [31] = false, [32] = false, [33] = false, [41] = false, [42] = false
			},
			[2] = {
				[0] = false, [11] = false, [12] = false, [13] = false, [21] = false, [22] = false,
				[23] = false, [31] = false, [32] = false, [33] = false, [41] = false, [42] = false
			},
			[3] = {
				[0] = false, [11] = false, [12] = false, [13] = false, [21] = false, [22] = false,
				[23] = false, [31] = false, [32] = false, [33] = false, [41] = false, [42] = false
			},
			[4] = {
				[0] = false, [11] = false, [12] = false, [13] = false, [21] = false, [22] = false,
				[23] = false, [31] = false, [32] = false, [33] = false, [41] = false, [42] = false
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

		-- RANK LEVEL
		self.current_points = 0
		self.max_level = 30

		-- GOLD INDICATOR
		self.current_gold = 0
		self.gold_init = 25
		self.gold_mult = 5

		if self.hero_name ~= nil then
			self:LoadSkills()
			self:LoadRanks()
			self:UpdatePanoramaPanels()
		end

		if IsInToolsMode() then
			self:AddGold(9999)
		else
			self:AddGold(60)
		end
	end

	function base_hero:LoadSkills()
		local skills_data = LoadKeyValues("scripts/vscripts/heroes/"..self.hero_name.."/"..self.hero_name.."-skills.txt")
		if skills_data ~= nil then
			for skill, skill_name in pairs(skills_data) do
				if skill < 4 then
					self.skills[skill] = skill_name
				else
					for id, extra_skill_name in pairs(skill_name) do
						self.skills[skill] = {}
						self.skills[skill][id] = extra_skill_name
					end
				end
			end
		end
	end

	function base_hero:LoadRanks()
		self.abilitiesData = LoadKeyValues("scripts/vscripts/heroes/"..self.hero_name.."/"..self.hero_name..".txt")
		local ranks_data = LoadKeyValues("scripts/vscripts/heroes/"..self.hero_name.."/"..self.hero_name.."-ranks.txt")
		if ranks_data == nil then return end

		for _,unit in pairs(ranks_data) do
			if not unit["min_level"] then
				for i = 0, 5, 1 do
					for tabName, tabData in pairs(unit) do
						local isTab = false
						if i == 5 then
							if tabName == "extras" then
								isTab = true
							end
						else
							if self.skills[i] then
								if tabName == self.skills[i] then
									isTab = true
								end
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
									
									if self.abilitiesData[talent] then
										talentData.MaxLevel = self.abilitiesData[talent]["MaxLevel"] or 1
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

	function base_hero:UpgradeRank(skill, id, level)
		local caster = self:GetCaster()
		local ability = nil
		
		if skill == 5 then
			self.extras_unlocked = self.extras_unlocked + 1
			ability = caster:FindAbilityByName(self.skills[skill][id])
			if not ability then return end
		else
			self.talents[skill][id] = true
			ability = caster:FindAbilityByName(self.skills[skill])
			if not ability then return end
			if not ability:IsTrained() then return end
		end

		ability:SetLevel(ability:GetLevel() + level)
		caster:AddExperience(level * 10, 0, false, false)
		SendOverheadEventMessage(nil, OVERHEAD_ALERT_SHARD, caster, level, caster)
	end

	function base_hero:AddGold(amount)
		self.current_gold = self.current_gold + amount
		local total_points = self:GetHeroRankLevel() + self.current_points
		if total_points >= self.max_level then self.current_gold = 0 return end
		self:CalculateGold()
	end

	function base_hero:CalculateGold()
		local total_points = self:GetHeroRankLevel() + self.current_points
		if total_points >= self.max_level then self.current_gold = 0 return end
		local current_gold_cost = self.gold_init + (self.gold_mult * total_points)

		if self.current_gold >= current_gold_cost then
			self.current_gold = self.current_gold - current_gold_cost
			self:AddTalentPointsToHero(1)
			self:CalculateGold()
		end
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
					if self:GetTalentRankLevel(talentId) == level
					and talent.Ability ~= "empty" then
						total = total + 1
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

		if left < 5 and self:GetTotalTalents(left) == 0 then
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

		-- Ancient 1.11 requires skill 4
		if self.talentsData[talentId].Ability == "ancient_1__berserk_rank_11"
		and (not self.talents[4][0]) then
			return false
		end

		-- Ancient 2.31 requires skill 1
		if self.talentsData[talentId].Ability == "ancient_2__leap_rank_31"
		and (not self.talents[1][0]) then
			return false
		end

		-- Ancient 4.31 requires skill 1
		if self.talentsData[talentId].Ability == "ancient_u__final_rank_31"
		and (not self.talents[1][0]) then
			return false
		end

		-- Bocuse 4.22 requires skill 1
		if self.talentsData[talentId].Ability == "bocuse_u__mise_rank_22"
		and (not self.talents[1][0]) then
			return false
		end

		-- Bocuse 4.42 requires rank level 21
		if self.talentsData[talentId].Ability == "bocuse_u__mise_rank_42" then
			local mise = self:GetCaster():FindAbilityByName("bocuse_u__mise")
			if mise == nil then return false end
			if mise:IsTrained() == false then return false end
			if mise:GetSpecialValueFor("rank") < 21 then return false end
		end

		for i = 1, 4, 1 do
			if self.talentsData[talentId].Tab == self.skills[i]
			and (not self.talents[i][0]) then
				return false
			end
		end

		if self.talentsData[talentId].Tab == "extras" then
			if (not self.talents[1][0]) or (not self.talents[2][0]) or (not self.talents[3][0]) or (not self.talents[4][0]) then
				return false
			else
				if self.extras_unlocked > 0 then
					if self:GetCaster():GetLevel() < 15 then
						return false
					end
				else
					if self:GetCaster():GetLevel() < 8 then
						return false
					end
				end
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

--PRECACHE
	function base_hero:Precache(context)
		if self:GetCaster():GetUnitName() == "npc_dota_hero_pudge" then
			PrecacheResource( "particle", "particles/bocuse/bocuse_msg.vpcf", context )
			PrecacheResource( "particle", "particles/bocuse/bocuse_strike_blur.vpcf", context )
			PrecacheResource( "particle", "particles/bocuse/bocuse_strike_blur_2.vpcf", context )
			PrecacheResource( "particle", "particles/bocuse/bocuse_strike_blur_3.vpcf", context )
			PrecacheResource( "particle", "particles/bocuse/bocuse_strike_blur_extra_1.vpcf", context )
			PrecacheResource( "particle", "particles/bocuse/bocuse_strike_blur_extra_2.vpcf", context )
			PrecacheResource( "particle", "particles/bocuse/bocuse_strike_blur_extra_3.vpcf", context )
			PrecacheResource( "particle", "particles/bocuse/bocuse_strike_blur_extra_4.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_bloodseeker/bloodseeker_bloodritual_impact.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodbath_eztzhok.vpcf", context )
			PrecacheResource( "particle", "particles/items3_fx/star_emblem.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/bloodseeker/bloodseeker_ti7/bloodseeker_ti7_thirst_owner.vpcf", context )
			PrecacheResource( "particle", "particles/bocuse/bocuse_flambee.vpcf", context )
			PrecacheResource( "particle", "particles/bocuse/bocuse_flambee_impact.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/alchemist/alchemist_smooth_criminal/alchemist_smooth_criminal_unstable_concoction_explosion.vpcf", context )
			PrecacheResource( "particle", "particles/bocuse/bocuse_flambee_impact_fire_ring.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/lifestealer/ls_ti9_immortal/status_effect_ls_ti9_open_wounds.vpcf", context )
			PrecacheResource( "particle", "particles/bocuse/bocuse_drunk_ally_crit.vpcf", context )
			PrecacheResource( "particle", "particles/bocuse/bocuse_drunk_enemy.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/bloodseeker/bloodseeker_eztzhok_weapon/bloodseeker_bloodrage_ground_eztzhok.vpcf", context )
			PrecacheResource( "particle", "particles/bocuse/bocuse_3_counter.vpcf", context )
			PrecacheResource( "particle", "particles/bocuse/bocuse_3_double_counter.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/invoker/invoker_ti7/status_effect_alacrity_ti7.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/doom/doom_ti8_immortal_arms/doom_ti8_immortal_devour.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/pudge/pudge_immortal_arm/pudge_immortal_arm_rot.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/ogre_magi/ogre_ti8_immortal_weapon/ogre_ti8_immortal_bloodlust_buff.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_grimstroke/grimstroke_cast2_ground.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_mars/mars_shield_bash_crit.vpcf", context )
			PrecacheResource( "particle", "particles/bocuse/bocuse_roux_debuff.vpcf", context )
			PrecacheResource( "particle", "particles/bocuse/bocuse_roux_aoe_mass.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_sandking/sandking_epicenter.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/meepo/meepo_colossal_crystal_chorus/meepo_divining_rod_poof_start.vpcf", context )
			PrecacheResource( "particle", "particles/items_fx/black_king_bar_avatar.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/wisp/wisp_relocate_teleport_ti7_out.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_secondstyle_debuff.vpcf", context )
			PrecacheResource( "particle", "particles/econ/items/techies/techies_arcana/techies_suicide_kills_arcana.vpcf", context )
			PrecacheResource( "particle", "particles/status_fx/status_effect_slark_shadow_dance.vpcf", context )
			PrecacheResource( "particle", "particles/units/heroes/hero_techies/techies_blast_off.vpcf", context )

			PrecacheResource( "model", "models/items/pudge/pudge_lord_of_decay_weapon/pudge_lord_of_decay_weapon.vmdl", context )
			PrecacheResource( "model", "models/items/pudge/pudge_insanity_chooper/pudge_insanity_chooper.vmdl", context )
			PrecacheResource( "model", "models/items/pudge/pudge_frozen_pig_face_head/pudge_frozen_pig_face_head.vmdl", context )
			PrecacheResource( "model", "models/items/pudge/the_ol_choppers_shoulder/the_ol_choppers_shoulder.vmdl", context )
			PrecacheResource( "model", "models/items/pudge/delicacies_back/delicacies_back.vmdl", context )
			PrecacheResource( "model", "models/items/pudge/doomsday_ripper_belt/doomsday_ripper_belt.vmdl", context )
			PrecacheResource( "model", "models/items/pudge/delicacies_arms/delicacies_arms.vmdl", context )
		end
	end