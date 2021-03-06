base_stats = class ({})
require("hero_stats_table")
LinkLuaModifier("base_stats_mod", "_basics/base_stats_mod", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("base_stats_mod_crit_bonus", "_basics/base_stats_mod_crit_bonus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_1_STR_modifier_stack", "modifiers/_1_STR_modifier_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_1_AGI_modifier_stack", "modifiers/_1_AGI_modifier_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_1_INT_modifier_stack", "modifiers/_1_INT_modifier_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_1_CON_modifier_stack", "modifiers/_1_CON_modifier_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_2_DEX_modifier_stack", "modifiers/_2_DEX_modifier_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_2_DEF_modifier_stack", "modifiers/_2_DEF_modifier_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_2_RES_modifier_stack", "modifiers/_2_RES_modifier_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_2_REC_modifier_stack", "modifiers/_2_REC_modifier_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_2_LCK_modifier_stack", "modifiers/_2_LCK_modifier_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_2_MND_modifier_stack", "modifiers/_2_MND_modifier_stack", LUA_MODIFIER_MOTION_NONE)

---- INIT
	-- ABILITY FUNCTIONS
		function base_stats:GetIntrinsicModifierName()
			return "base_stats_mod"
		end

		function base_stats:Spawn()
			if IsServer() then
				if self:IsTrained() == false then
					self:UpgradeAbility(true)
				end
			end
		end

		function base_stats:OnUpgrade()
		end

		function base_stats:OnHeroLevelUp()
			if IsServer() then
				local caster = self:GetCaster()
				local level = caster:GetLevel()
				if caster:IsIllusion() then return end

				self:IncrementSpenderPoints(1, 3)
				for _, stat in pairs(self.stats_primary) do
					self:IncrementSubLevel(stat, self.bonus_level[stat])
				end
			end
		end

		function base_stats:OnOwnerSpawned()
		end

	-- LOAD STATS
		function base_stats:ResetAllStats()
			if IsServer() then
				self.primary_points = 0
				self.secondary_points = 0

				self.stat_init = {}
				self.stat_base = {}
				self.stat_bonus = {}
				self.stat_total = {}
				self.stat_percent = {}
				self.stat_sub_level = {}
				self.stat_fraction = {}
				self.stat_levelup = {} -- LEVEL UP COUNT
				self.bonus_level = {} -- CONST SPECIAL VALUE
				

				self.stats_primary = {
					"STR", "AGI", "INT", "CON"
				}

				self.stats_secondary = {
					"DEX", "DEF", "RES", "REC", "LCK", "MND"
				}


				for _, stat in pairs(self.stats_primary) do
					self.stat_init[stat] = 0
					self.stat_base[stat] = 0
					self.stat_bonus[stat] = 0
					self.stat_total[stat] = 0
					self.stat_percent[stat] = 0
					self.stat_sub_level[stat] = 0
					self.stat_fraction[stat] = {}
					self.stat_levelup[stat] = 0
				end

				for _, stat in pairs(self.stats_secondary) do
					self.stat_init[stat] = 0
					self.stat_base[stat] = 0
					self.stat_bonus[stat] = 0
					self.stat_total[stat] = 0
					self.stat_percent[stat] = 0
					self.stat_sub_level[stat] = 0
					self.stat_fraction[stat] = {}
					self.stat_levelup[stat] = 0
				end

				self.stat_fraction["STR"] = {["value"] = 0, "DEF", "LCK", "DEX"}
				self.stat_fraction["AGI"] = {["value"] = 0, "DEX", "REC", "MND"}
				self.stat_fraction["INT"] = {["value"] = 0, "LCK", "REC", "RES"}
				self.stat_fraction["CON"] = {["value"] = 0, "DEF", "RES", "MND"}
				self.stat_fraction["DEX"] = {["value"] = 0, "AGI", "STR"}
				self.stat_fraction["DEF"] = {["value"] = 0, "CON", "STR"}
				self.stat_fraction["RES"] = {["value"] = 0, "INT", "CON"}
				self.stat_fraction["REC"] = {["value"] = 0, "AGI", "INT"}
				self.stat_fraction["LCK"] = {["value"] = 0, "INT", "STR"}
				self.stat_fraction["MND"] = {["value"] = 0, "AGI", "CON"}
			end
		end

		function base_stats:AddBaseStatsPoints()
			if IsServer() then
				local caster = self:GetCaster()
				local heroes_stats_data = LoadKeyValues("scripts/kv/heroes_stats.kv")
				local hero_name = nil

				if caster:GetUnitName() == "npc_dota_hero_shadow_shaman" then hero_name = "dasdingo" end
				if caster:GetUnitName() == "npc_dota_hero_riki" then hero_name = "icebreaker" end
				if caster:GetUnitName() == "npc_dota_hero_drow_ranger" then hero_name = "genuine" end
				if caster:GetUnitName() == "npc_dota_hero_dawnbreaker" then hero_name = "striker" end

				if hero_name == nil then return end
				if heroes_stats_data == nil then return end

				self:ResetAllStats()

				for hero, hero_stats in pairs(heroes_stats_data) do
					if hero == hero_name then
						for stat, stats_type in pairs(hero_stats) do
							for stat_type, value in pairs(stats_type) do
								if stat_type == "initial" then
									self.stat_init[stat] = value
									self.stat_base[stat] = self.stat_base[stat] + value
									self:CalculateStats(0, 0, stat)
									self:IncrementFraction(stat, value * 3)
								elseif stat_type == "bonus_level" then
									self.bonus_level[stat] = value
									self:IncrementSubLevel(stat, value)
								end
							end
						end
					end
				end
			end
		end

		function base_stats:LoadSpecialValues()
			if IsServer() then
				-- STR
				self.damage = self:GetSpecialValueFor("damage")
				self.critical_damage = self:GetSpecialValueFor("critical_damage")
				self.range = self:GetSpecialValueFor("range")
				self.base_block_damage = self:GetSpecialValueFor("base_block_damage")
				self.block_damage = self:GetSpecialValueFor("block_damage")
				self.block_chance = self:GetSpecialValueFor("block_chance")
				self.physical_block = 0
				self.magical_block = 0

				-- AGI
				self.movespeed = self:GetSpecialValueFor("movespeed")
				self.base_movespeed = self:GetSpecialValueFor("base_movespeed")
				self.attack_speed = self:GetSpecialValueFor("attack_speed")
				self.base_attack_time = self:GetSpecialValueFor("base_attack_time")
				self.attack_time = self.base_attack_time

				-- INT
				self.mana = self:GetSpecialValueFor("mana")
				self.spell_amp = self:GetSpecialValueFor("spell_amp")

				-- CON
				self.health_bonus = self:GetSpecialValueFor("health_bonus")
				self.health_regen = self:GetSpecialValueFor("health_regen")
				self.heal_amplify = self:GetSpecialValueFor("heal_amplify")
				self.regen_state = 1	

				-- SECONDARY
				self.evade = self:GetSpecialValueFor("evade") 
				self.armor = self:GetSpecialValueFor("armor")
				self.resistance = self:GetSpecialValueFor("resistance")
				self.mana_regen = self:GetSpecialValueFor("mana_regen")
				self.cooldown = self:GetSpecialValueFor("cooldown")
				self.heal_power = self:GetSpecialValueFor("heal_power")
				self.buff_amp = self:GetSpecialValueFor("buff_amp")

				-- CRITICAL
				self.critical_chance = self:GetSpecialValueFor("critical_chance")
				self.crit_damage_spell = {[DAMAGE_TYPE_PHYSICAL] = 0, [DAMAGE_TYPE_MAGICAL] = 0}
				self.force_crit_spell = {[DAMAGE_TYPE_PHYSICAL] = false, [DAMAGE_TYPE_MAGICAL] = false}
				self.total_crit_damage = self:CalcCritDamage(nil)
				self.force_crit_hit = false
				self.has_crit = false

				-- INIT
				self.total_range = self.range * self.stat_init["STR"]
				self.total_block_damage = self.base_block_damage + (self.block_damage * self.stat_init["STR"])
				self.total_movespeed = self.base_movespeed + (self.movespeed * self.stat_init["AGI"])
				self.total_mana = self.mana * self.stat_init["INT"]
				self.total_heal_amplify = self.heal_amplify * self.stat_init["CON"]
			end
		end

		function base_stats:LoadDataForIllusion()
			if IsServer() then
				local hero_stats = nil
				local hero = self:FindOriginalHero()
				if hero then hero_stats = hero:FindAbilityByName("base_stats") end
				if hero_stats == nil then return end

				self.stat_base = hero_stats.stat_base
				self.stat_bonus = hero_stats.stat_bonus
				self.stat_percent = hero_stats.stat_percent
				self.stat_total = hero_stats.stat_total

				-- STR
				self.damage = hero_stats.damage
				self.critical_damage = hero_stats.critical_damage
				self.range = hero_stats.range
				self.base_block_damage = hero_stats.base_block_damage
				self.block_damage = hero_stats.block_damage
				self.block_chance = hero_stats.block_chance
				self.physical_block = hero_stats.physical_block
				self.magical_block = hero_stats.magical_block

				-- AGI
				self.movespeed = hero_stats.movespeed
				self.base_movespeed = hero_stats.base_movespeed
				self.attack_speed = hero_stats.attack_speed
				self.base_attack_time = hero_stats.base_attack_time
				self.attack_time = hero_stats.attack_time

				-- INT
				self.mana = hero_stats.mana
				self.spell_amp = hero_stats.spell_amp

				-- CON
				self.health_bonus = hero_stats.health_bonus
				self.health_regen = hero_stats.health_regen
				self.heal_amplify = hero_stats.heal_amplify
				self.regen_state = hero_stats.regen_state

				-- SECONDARY
				self.evade = hero_stats.evade
				self.armor = hero_stats.armor
				self.resistance = hero_stats.resistance
				self.mana_regen = hero_stats.mana_regen
				self.cooldown = hero_stats.cooldown
				self.heal_power = hero_stats.heal_power
				self.buff_amp = hero_stats.buff_amp

				-- CRITICAL
				self.critical_chance = hero_stats.critical_chance
				self.crit_damage_spell = hero_stats.crit_damage_spell
				self.force_crit_spell = hero_stats.force_crit_spell
				self.total_crit_damage = hero_stats.total_crit_damage
				self.force_crit_hit = hero_stats.force_crit_hit
				self.has_crit = hero_stats.has_crit

				-- INIT
				self.total_range = hero_stats.total_range
				self.total_block_damage = hero_stats.total_block_damage
				self.total_movespeed = hero_stats.total_movespeed
				self.total_mana = hero_stats.total_mana
				self.total_heal_amplify = hero_stats.total_heal_amplify
			end
		end

		function base_stats:FindOriginalHero()
			if IsServer() then
				local maxPlayers = 4
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
							local hPlayer = PlayerResource:GetPlayer(playerID)
							if hPlayer ~= nil then
								local assigned_hero = hPlayer:GetAssignedHero()
								if assigned_hero ~= nil then
									if assigned_hero:IsIllusion() == false then
										if assigned_hero:GetUnitName() == self:GetCaster():GetUnitName() then
											return assigned_hero
										end
									end
								end
							end
						end
					end
				end
			end
		end

---- ATTRIBUTES POINTS
	-- ADD SPENDER POINTS AND UPDATE PANORAMA
		function base_stats:IncrementSpenderPoints(primary, secondary)
			if IsServer() then
				self.primary_points = self.primary_points + primary
				self.secondary_points = self.secondary_points + secondary
				self:UpdatePanoramaPoints()
			end
		end

		function base_stats:UpdatePanoramaStat(stat)
			if IsServer() then
				local player = self:GetCaster():GetPlayerOwner()
				if (not player) then return end

				CustomGameEventManager:Send_ServerToPlayer(player, "stats_state_from_server", {
					stat = stat,
					base = self.stat_base[stat],
					bonus = self.stat_bonus[stat],
					total = self.stat_total[stat]
				})
			end
		end

		function base_stats:UpdatePanoramaPoints()
			if IsServer() then
				local player = self:GetCaster():GetPlayerOwner()
				if (not player) then return end

				CustomGameEventManager:Send_ServerToPlayer(player, "points_state_from_server", {
					primary = self.primary_points,
					secondary = self.secondary_points,
					stats_level = self.stat_levelup,
					hero_level = self:GetCaster():GetLevel()
				})
			end
		end

	-- APPLY STATS
		function base_stats:AddBonusStat(attacker, ability, static_value, percent_value, duration, string)
			if IsServer() then
				local target = self:GetCaster()
				local stringFormat = string.format("%s_modifier_stack", string)

				target:AddNewModifier(attacker, ability, stringFormat, {
					duration = duration, stacks = static_value, percent = percent_value
				})
			end
		end

		function base_stats:CalculateStats(static_value, percent_value, stat)
			if IsServer() then
				self.stat_bonus[stat] = self.stat_bonus[stat] + static_value
				self.stat_percent[stat] = self.stat_percent[stat] + percent_value

				self.stat_total[stat] = self.stat_base[stat] + self.stat_bonus[stat]
				if self.stat_total[stat] < 0 then self.stat_total[stat] = 0 end

				self.stat_total[stat] = self.stat_total[stat] + math.floor(
					self.stat_total[stat] * self.stat_percent[stat] * 0.01
				)

				if self.stat_total[stat] > 150 then self.stat_total[stat] = 150 end
				if self.stat_total[stat] < 0 then self.stat_total[stat] = 0 end

				if stat == "REC" then
					local channel = self:GetCaster():FindAbilityByName("_channel")
					if channel then channel:SetLevel(self.stat_total["REC"]) end
				end

				local void = self:GetCaster():FindAbilityByName("_void")
				if void then void:SetLevel(1) end

				if self:GetCaster():IsIllusion() then return end

				self:UpdatePanoramaStat(stat)
			end
		end

		function base_stats:AddBaseStat(stat, amount)
			if IsServer() then
				self.stat_base[stat] = self.stat_base[stat] + amount
				self:CalculateStats(0, 0, stat)
			end
		end

	-- PASSIVE LEVELUP PTS AND FRACTION CALC
		function base_stats:IncrementSubLevel(stat, value)
			if IsServer() then
				self.stat_sub_level[stat] = self.stat_sub_level[stat] + value
				if self.stat_sub_level[stat] > 1 then
					self.stat_sub_level[stat] = self.stat_sub_level[stat] - 1
					self.stat_base[stat] = self.stat_base[stat] + 1
					self:IncrementFraction(stat, 3)
					self:CalculateStats(0, 0, stat)
				end
			end
		end

		function base_stats:IncrementFraction(stat, value)
			if IsServer() then
				for index, stat_fraction in pairs(self.stat_fraction[stat]) do
					if index ~= "value" then
						self.stat_fraction[stat_fraction]["value"] = self.stat_fraction[stat_fraction]["value"] + value
						local levelup = 0
						while self.stat_fraction[stat_fraction]["value"] >= 6 do
							self.stat_fraction[stat_fraction]["value"] = self.stat_fraction[stat_fraction]["value"] - 6
							levelup = levelup + 1
						end

						if levelup > 0 then
							self.stat_base[stat_fraction] = self.stat_base[stat_fraction] + levelup
							self:CalculateStats(0, 0, stat_fraction)
						end
					end
				end
			end
		end

---- ATTRIBUTES UTILS
	-- UTIL STR

		function base_stats:SetForceCritSpell(value, state, damage_type)
			if value > 0 then self.crit_damage_spell[damage_type] = value end
			self.force_crit_spell[damage_type] = state -- NIL == force no crit
		end

		function base_stats:SetForceCritHit(value)
			if value > 0 then self.total_crit_damage = value end
			self.force_crit_hit = true
		end

		function base_stats:CalcCritDamage(damage_type)
			if IsServer() then
				local caster = self:GetCaster()
				local bonus_value = 0
				local mods = caster:FindAllModifiersByName("base_stats_mod_crit_bonus")
				for _,mod in pairs(mods) do
					bonus_value = bonus_value + mod:GetStackCount()
				end

				local total_crit_dmg = self.critical_damage

				if caster:HasModifier("ancient_1_modifier_berserk")
				and damage_type == DAMAGE_TYPE_PHYSICAL then
					local chance_base = 0.25
					local chance_luck = self:GetCriticalChance() * 0.005
					local crit_dmg = ((self.critical_damage - 100) * 3) * 0.01
					local time = 0

					if self.stat_total["AGI"] > 0 then time = self.stat_total["AGI"] / 120 end

					local agi_crit_dmg = (time * (1 + (crit_dmg * chance_base) + (crit_dmg * chance_luck))) / (chance_base + chance_luck)
					total_crit_dmg = math.floor((crit_dmg + agi_crit_dmg) * 100) + 100
				end

				return total_crit_dmg + bonus_value
			end
		end

		function base_stats:RollChance()
			if IsServer() then
				local caster = self:GetCaster()
				local critical_chance = self:GetCriticalChance()

				if caster:HasModifier("ancient_1_modifier_berserk") then
					critical_chance = (critical_chance * 0.5) + 25
				end

				if RandomFloat(1, 100) <= critical_chance * self.critical_chance then
					return true
				end
				
				return false
			end
		end

	-- UTIL AGI

		function base_stats:SetBaseAttackTime(bonus)
			if IsServer() then
				local caster = self:GetCaster()
				if caster:HasModifier("ancient_1_modifier_berserk") then
					self.attack_time = 2.25 + bonus
					return
				end

				self.attack_time = self.base_attack_time + bonus
			end
		end

	-- UTIL INT

		function base_stats:GetSpellAmp()
			return self.stat_total["INT"] * self.spell_amp * 0.01
		end

	-- UTIL CON

		function base_stats:SetRegenState(bool)
			if bool == true then self.regen_state = 1 else self.regen_state = 0 end
		end

	-- UTIL LCK

		function base_stats:GetCriticalChance()
			return 1 + (self.stat_total["LCK"] * 0.01)
			-- local value = self.stat_total["LCK"] * self.critical_chance -- 0.25
			-- local calc = (value * 6) / (1 +  (value * 0.04))
			-- return calc
		end

	-- UTIL MND

		function base_stats:GetHealPower()
			return 1 + (self.stat_total["MND"] * self.heal_power * 0.01)
		end

		function base_stats:GetBuffAmp()
			return self.stat_total["MND"] * self.buff_amp * 0.01
		end