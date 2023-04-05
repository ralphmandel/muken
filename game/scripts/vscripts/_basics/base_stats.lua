base_stats = class ({})
require("internal/hero_stats_table")
--require("examples/worldpanelsExample")
LinkLuaModifier("base_stats_mod", "_basics/base_stats_mod", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("base_stats_mod_crit_bonus", "_basics/base_stats_mod_crit_bonus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("base_stats_mod_block_bonus", "_basics/base_stats_mod_block_bonus", LUA_MODIFIER_MOTION_NONE)
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
				if caster:IsHero() == false then return end

				for _, stat in pairs(self.stats_primary) do
					self:ApplyBonusLevel(stat, self.bonus_level[stat])
				end
        self:IncrementSpenderPoints()
			end
		end

		function base_stats:OnOwnerSpawned()
		end

	-- LOAD STATS
		function base_stats:ResetAllStats()
			if IsServer() then
				self.total_points = 0

				self.stat_base = {}
				self.stat_bonus = {}
				self.stat_total = {}
				self.stat_percent = {}
				self.stat_sub_level = {}
				self.bonus_level = {} -- CONST SPECIAL VALUE
        self.stat_fraction = {["level_up"] = {}, ["plus_up"] = {}}

				self.stats_primary = {
					"STR", "AGI", "INT", "CON"
				}

				self.stats_secondary = {
					"DEX", "DEF", "RES", "REC", "LCK", "MND"
				}

				for _, stat in pairs(self.stats_primary) do
					self.stat_base[stat] = 0
					self.stat_bonus[stat] = 0
					self.stat_total[stat] = 0
					self.stat_percent[stat] = 0
					self.stat_sub_level[stat] = 0
					self.stat_fraction["level_up"][stat] = {}
					self.stat_fraction["plus_up"][stat] = {}
				end

				for _, stat in pairs(self.stats_secondary) do
					self.stat_base[stat] = 0
					self.stat_bonus[stat] = 0
					self.stat_total[stat] = 0
					self.stat_percent[stat] = 0
					self.stat_sub_level[stat] = 0
					self.stat_fraction["level_up"][stat] = {}
					self.stat_fraction["plus_up"][stat] = {}
				end


        for type, table in pairs(self.stat_fraction) do
          self.stat_fraction[type]["STR"] = {["value"] = 0, "DEF", "RES", "LCK"}
          self.stat_fraction[type]["AGI"] = {["value"] = 0, "DEX", "REC", "LCK"}
          self.stat_fraction[type]["INT"] = {["value"] = 0, "MND", "REC", "RES"}
          self.stat_fraction[type]["CON"] = {["value"] = 0, "DEF", "DEX", "MND"}
          self.stat_fraction[type]["DEX"] = {["value"] = 0, "AGI", "CON"}
          self.stat_fraction[type]["DEF"] = {["value"] = 0, "CON", "STR"}
          self.stat_fraction[type]["RES"] = {["value"] = 0, "INT", "STR"}
          self.stat_fraction[type]["REC"] = {["value"] = 0, "AGI", "INT"}
          self.stat_fraction[type]["LCK"] = {["value"] = 0, "AGI", "STR"}
          self.stat_fraction[type]["MND"] = {["value"] = 0, "INT", "CON"}          
        end
			end
		end

		function base_stats:AddBaseStatsPoints()
			if IsServer() then
				local caster = self:GetCaster()
				local unit_stats = nil
				local heroes_name_data = LoadKeyValues("scripts/npc/heroes_name.kv")
				local heroes_stats_data = LoadKeyValues("scripts/npc/heroes_stats.kv")
				local boss_list = LoadKeyValues("scripts/vscripts/bosses/_bosses_units.txt")
				local neutral_list = LoadKeyValues("scripts/vscripts/neutrals/_neutrals_units.txt")

				if heroes_name_data then
					for name, id_name in pairs(heroes_name_data) do
						if caster:GetUnitName() == id_name then
							for hero, hero_stats in pairs(heroes_stats_data) do
								if hero == name then
									unit_stats = hero_stats
								end
							end
						end
					end
				end	

				if unit_stats == nil then
					for name, table in pairs(boss_list) do
						if name == caster:GetUnitName() then
							for info, stats in pairs(table) do
								if info == "Stats" then
									unit_stats = stats
								end
							end
						end
					end
				end

				if unit_stats == nil then
					for name, table in pairs(neutral_list) do
						if name == caster:GetUnitName() then
							for info, stats in pairs(table) do
								if info == "Stats" then
									unit_stats = stats
								end
							end
						end
					end
				end

				if unit_stats == nil then return end

				self:ResetAllStats()

        if caster:IsHero() then
          for stat, stats_type in pairs(unit_stats) do
            for stat_type, value in pairs(stats_type) do
              if stat_type == "initial" then
                self.stat_base[stat] = self.stat_base[stat] + value
                self:CalculateStats(0, 0, stat)
                self:IncrementFraction("level_up", stat, value * 3)
              elseif stat_type == "bonus_level" then
                self.bonus_level[stat] = value
              end
            end
          end
        else
          for stat, value in pairs(unit_stats) do
            self.stat_base[stat] = self.stat_base[stat] + value
            self:CalculateStats(0, 0, stat)
            self:IncrementFraction("level_up", stat, value * 3)
          end
        end
			end
		end

		function base_stats:LoadSpecialValues()
			if IsServer() then
				-- STR
				self.critical_damage = self:GetSpecialValueFor("critical_damage")
				self.base_critical_damage = self:GetSpecialValueFor("base_critical_damage")
				self.damage = self:GetSpecialValueFor("damage")

				-- BLOCK
				self.physical_block_max_percent = self:GetSpecialValueFor("physical_block_max_percent")
				self.magical_block_max_percent = self:GetSpecialValueFor("magical_block_max_percent")

				-- AGI
				self.movespeed = self:GetSpecialValueFor("movespeed")
				self.base_movespeed = self:GetSpecialValueFor("base_movespeed")
				self.attack_speed = self:GetSpecialValueFor("attack_speed")
				self.base_attack_time = self:GetSpecialValueFor("base_attack_time")
				self.attack_time = self.base_attack_time
				self.bonus_attack_time = 0
        self.bonus_movespeed = {}

				-- INT
				self.mana = self:GetSpecialValueFor("mana")
				self.debuff_amp = self:GetSpecialValueFor("debuff_amp")
        self.spell_amp = self:GetSpecialValueFor("spell_amp")
				self.mana_regen = self:GetSpecialValueFor("mana_regen")
				self:SetMPRegenState(0)

				-- CON
				self.status_resist = self:GetSpecialValueFor("status_resist")
				self.health_bonus = self:GetSpecialValueFor("health_bonus")
				self.health_regen = self:GetSpecialValueFor("health_regen")
				self.hp_regen_state = 1

				-- SECONDARY
				self.evade = self:GetSpecialValueFor("evade") 
				self.armor = self:GetSpecialValueFor("armor")
				self.magic_resist = self:GetSpecialValueFor("magic_resist")
				self.cooldown = self:GetSpecialValueFor("cooldown")
				self.heal_power = self:GetSpecialValueFor("heal_power")
				self.buff_amp = self:GetSpecialValueFor("buff_amp")
				self.critical_chance = self:GetSpecialValueFor("critical_chance")

				-- CRITICAL
				self.force_crit_chance = nil
				self.force_crit_damage = nil
			end
		end

		function base_stats:LoadDataForIllusion()
			if IsServer() then
				local hero_stats = nil
				local hero = self:FindOriginalHero()
				if hero then hero_stats = hero:FindAbilityByName("base_stats") end
				if hero_stats == nil then return end

				self.stat_base = {}
				self.stat_bonus = {}
				self.stat_total = {}
				self.stat_percent = {}
				self.stats_primary = {"STR", "AGI", "INT", "CON"}
				self.stats_secondary = {"DEX", "DEF", "RES", "REC", "LCK", "MND"}

				for _, stat in pairs(self.stats_primary) do
					self.stat_base[stat] = hero_stats:GetStatBase(stat)
					self.stat_bonus[stat] = 0
					self.stat_total[stat] = hero_stats:GetStatTotal(stat)
					self.stat_percent[stat] = 0
					--self:CalculateStats(0, 0, stat)
				end

				for _, stat in pairs(self.stats_secondary) do
					self.stat_base[stat] = hero_stats:GetStatBase(stat)
					self.stat_bonus[stat] = 0
					self.stat_total[stat] = hero_stats:GetStatTotal(stat)
					self.stat_percent[stat] = 0
					--self:CalculateStats(0, 0, stat)
				end
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
					-- [5] = DOTA_TEAM_CUSTOM_5,
					-- [6] = DOTA_TEAM_CUSTOM_6,
					-- [7] = DOTA_TEAM_CUSTOM_7,
					-- [8] = DOTA_TEAM_CUSTOM_8
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

	-- GET STATS
		function base_stats:GetStatBase(stat)
			local value = self.stat_base[stat]
			return value
		end

		function base_stats:GetStatBonus(stat)
			local value = self.stat_bonus[stat]
			return value
		end

		function base_stats:GetStatTotal(stat)
			local value = self.stat_total[stat]
			return value
		end

		function base_stats:GetStatPercent(stat)
			local value = self.stat_percent[stat]
			return value
		end

---- ATTRIBUTES POINTS
	-- ADD SPENDER POINTS AND UPDATE PANORAMA
		function base_stats:IncrementSpenderPoints()
			if IsServer() then
				self.total_points = self.total_points + 5
				if self:GetCaster():IsHero() then self:UpdatePanoramaPoints("nil") end
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

		function base_stats:UpdatePanoramaPoints(upgraded_stat)
			if IsServer() then
				local player = self:GetCaster():GetPlayerOwner()
				if (not player) then return end

        local stats = {}
        local stats_fraction = {}

        for _, stat in pairs(self.stats_primary) do
          stats[stat] = self:IsHeroCanLevelUpStat(stat)
          stats_fraction[stat] = self.stat_fraction["plus_up"][stat]["value"] == 4
				end

        for _, stat in pairs(self.stats_secondary) do
          stats[stat] = self:IsHeroCanLevelUpStat(stat)
          stats_fraction[stat] = self.stat_fraction["plus_up"][stat]["value"] == 3
				end

				CustomGameEventManager:Send_ServerToPlayer(player, "points_state_from_server", {
					total_points = self.total_points,
					stats = stats,
          stats_fraction = stats_fraction,
          upgraded_stat = upgraded_stat
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

				if self.stat_total[stat] > 99 then self.stat_total[stat] = 99 end
				if self.stat_total[stat] < 0 then self.stat_total[stat] = 0 end

				if stat == "REC" then
					local channel = self:GetCaster():FindAbilityByName("_channel")
					if channel then channel:SetLevel(self.stat_total["REC"]) end
				end

				local void = self:GetCaster():FindAbilityByName("_void")
				if void then void:SetLevel(1) end

				if self:GetCaster():IsIllusion() then return end
				if self:GetCaster():IsHero() == false then return end

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
		function base_stats:ApplyBonusLevel(stat, value)
			if IsServer() then
				self.stat_sub_level[stat] = self.stat_sub_level[stat] + value
        if stat == "INT" then print("INT", self.stat_sub_level[stat]) end
				if self.stat_sub_level[stat] >= 20 then
					self.stat_sub_level[stat] = self.stat_sub_level[stat] - 20
					self.stat_base[stat] = self.stat_base[stat] + 1
					self:IncrementFraction("level_up", stat, 3)
					self:CalculateStats(0, 0, stat)
					self:ApplyBonusLevel(stat, 0)
				end
			end
		end

		function base_stats:IncrementFraction(type, stat, value)
			if IsServer() then
				for index, stat_fraction in pairs(self.stat_fraction[type][stat]) do
					if index ~= "value" then
						self.stat_fraction[type][stat_fraction]["value"] = self.stat_fraction[type][stat_fraction]["value"] + value
						local levelup = 0
						while self.stat_fraction[type][stat_fraction]["value"] >= 6 do
							self.stat_fraction[type][stat_fraction]["value"] = self.stat_fraction[type][stat_fraction]["value"] - 6
							levelup = levelup + 1
						end

						if levelup > 0 then
              if type == "plus_up" then self.total_points = self.total_points - levelup end
							self.stat_base[stat_fraction] = self.stat_base[stat_fraction] + levelup
							self:CalculateStats(0, 0, stat_fraction)
						end
					end
				end
			end
		end

    function base_stats:IsHeroCanLevelUpStat(stat)
      local caster = self:GetCaster()
      local level_cap = caster:GetLevel() + 30
      local total_cost = 1

      for index, stat_fraction in pairs(self.stat_fraction["plus_up"][stat]) do
        if index ~= "value" then
          if self.stat_base[stat_fraction] >= level_cap then return false end
          total_cost = total_cost + self:GetSubCost(stat_fraction, self.stats_primary, 4)
          total_cost = total_cost + self:GetSubCost(stat_fraction, self.stats_secondary, 3)
        end
      end

      return (level_cap > self.stat_base[stat]) and (self.total_points >= total_cost)
    end

    function base_stats:GetSubCost(stat_fraction, table, number)
      local cost = 0
      for _, table_stat in pairs(table) do
        if stat_fraction == table_stat then
          if self.stat_fraction["plus_up"][stat_fraction]["value"] == number then
            cost = cost + 1
          end            
        end
      end      
      return cost
    end

---- ATTRIBUTES UTILS
	-- UTIL STR

    function base_stats:GetTotalPhysicalDamagePercent()
      return 100 + (self.stat_total["STR"] * 5)
    end

		function base_stats:SetForceCrit(chance, damage)
			self.force_crit_chance = chance
			self.force_crit_damage = damage
		end

    function base_stats:GetCriticalDamage()
      local result = self.force_crit_damage
      if result == nil then
        result = self.base_critical_damage + (self.critical_damage * (self.stat_base["STR"]))
      end

      return result
		end

	-- UTIL AGI

    function base_stats:GetBaseMS()
      return self.base_movespeed + (self.movespeed * self.stat_base["AGI"])
    end

    function base_stats:GetBonusMS()
      local caster = self:GetCaster()
      local amount = 0

      local buff = caster:FindAllModifiersByName("_modifier_movespeed_buff")
      for _,modifier in pairs(buff) do
        amount = amount + modifier:GetStackCount()
      end

      if caster:HasModifier("_modifier_unslowable") == false then
        local debuff = caster:FindAllModifiersByName("_modifier_movespeed_debuff")
        for _,modifier in pairs(debuff) do
          amount = amount - modifier:GetStackCount()
        end       
      end

      return amount
    end

    function base_stats:GetPercentMS()
      local caster = self:GetCaster()
      local amount = 0

      local buff = caster:FindAllModifiersByName("_modifier_percent_movespeed_buff")
      for _,modifier in pairs(buff) do
        amount = amount + modifier:GetStackCount()
      end

      if caster:HasModifier("_modifier_unslowable") == false then
        local debuff = caster:FindAllModifiersByName("_modifier_percent_movespeed_debuff")
        for _,modifier in pairs(debuff) do
          amount = amount - modifier:GetStackCount()
        end  
      end

      amount = 1 + (amount * 0.01)

      if amount > 2 then return 2 end
      if amount < 0 then return 0 end

      return amount
    end

		function base_stats:SetBaseAttackTime(bonus)
			if IsServer() then
				self.bonus_attack_time = bonus
				self:UpdateBaseAttackTime()
			end
		end

		function base_stats:UpdateBaseAttackTime()
			if IsServer() then
				local caster = self:GetCaster()
				local attack_time = 0
				local ancient_mod = caster:FindModifierByName("ancient_1_modifier_passive")
				local mirepoix_mod = caster:FindModifierByName("bocuse_4_modifier_mirepoix")

				if ancient_mod then
					if ancient_mod:GetStackCount() > 0 then attack_time = 2.5 else attack_time = 1 end
				elseif caster:GetUnitName() == "tribal_ward" then
					attack_time = 1.5
				else
					attack_time = self.base_attack_time
				end

				if mirepoix_mod then
					attack_time = mirepoix_mod:GetAbility():GetSpecialValueFor("base_aspd")
				end

				self.attack_time = attack_time + self.bonus_attack_time
			end
		end

	-- UTIL INT

    function base_stats:GetTotalMagicalDamagePercent()
      return 100 + (self.stat_total["INT"] * self.spell_amp)
    end

    function base_stats:GetTotalDebuffAmpPercent()
      local caster = self:GetCaster()
      local percent = 100 + (self.stat_base["INT"] * self.debuff_amp)
      local mods_increase = caster:FindAllModifiersByName("_modifier_debuff_increase")
			for _,modifier in pairs(mods_increase) do
				percent = percent + modifier:GetStackCount()
			end

      return percent
    end

		function base_stats:GetDebuffAmp()
			local caster = self:GetCaster()
			local bonus = self.stat_base["INT"] * self.debuff_amp

			local mods_increase = caster:FindAllModifiersByName("_modifier_debuff_increase")
			for _,modifier in pairs(mods_increase) do
				bonus = bonus + modifier:GetStackCount()
			end

			return bonus * 0.01
		end

		function base_stats:SetMPRegenState(stack)
			if not self.mp_regen_stack then self.mp_regen_stack = 1 end
			self.mp_regen_stack = self.mp_regen_stack + stack
			
			if self.mp_regen_stack > 0 then
				self.mp_regen_state = 1
				self:GetCaster():SetBaseManaRegen(10)
			else
				self.mp_regen_state = 0
				self:GetCaster():SetBaseManaRegen(0)
			end
		end

	-- UTIL CON

    function base_stats:GetStatusResistPercent()
      if self:GetCaster():IsHero() then return self:GetCaster():GetStatusResistance() * 100 end
      return self.status_resist * (self.stat_base["CON"])
    end

		function base_stats:SetHPRegenState(bool)
			if bool == true then self.hp_regen_state = 1 else self.hp_regen_state = 0 end
		end

	-- UTIL LCK

		function base_stats:GetCriticalChance()
      local result = self.force_crit_chance
      if result == nil then
        result = (1 + self.stat_total["LCK"]) * self.critical_chance
      end

      return result
		end

  -- UTIL DEX

    function base_stats:GetMissPercent()
      local caster = self:GetCaster()
      local blind = caster:FindModifierByName("_modifier_blind_stack")
      if blind then return blind:GetStackCount() end
      return 0
    end

    function base_stats:GetDodgePercent()
      local value = self.stat_total["DEX"] * self.evade
      local calc = (value * 6) / (1 +  (value * 0.06))
      return calc
    end

	-- UTIL MND

    function base_stats:GetTotalHealPowerPercent()
      return 100 + (self.stat_total["MND"] * self.heal_power)
    end

    function base_stats:GetTotalBuffAmpPercent()
      return 100 + (self.stat_total["MND"] * self.buff_amp)
    end

		function base_stats:GetHealPower()
			return 1 + (self.stat_total["MND"] * self.heal_power * 0.01)
		end

		function base_stats:GetBuffAmp()
			return self.stat_total["MND"] * self.buff_amp * 0.01
		end

	-- if caster:HasModifier("ancient_1_modifier_passive")
	-- and damage_type == DAMAGE_TYPE_PHYSICAL then
	-- 	local chance_base = 0.25
	-- 	local chance_luck = self:GetCritChance() * 0.005
	-- 	local crit_dmg = ((self.critical_damage - 100) * 3) * 0.01
	-- 	local time = 0

	-- 	if self.stat_total["AGI"] > 0 then time = self.stat_total["AGI"] / 120 end

	-- 	local agi_crit_dmg = (time * (1 + (crit_dmg * chance_base) + (crit_dmg * chance_luck))) / (chance_base + chance_luck)
	-- 	total_crit_dmg = math.floor((crit_dmg + agi_crit_dmg) * 100) + 100
	-- end