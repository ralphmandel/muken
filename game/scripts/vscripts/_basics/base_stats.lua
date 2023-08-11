base_stats = class ({})
require("internal/hero_stats_table")
--require("examples/worldpanelsExample")
LinkLuaModifier("base_stats_mod", "_basics/base_stats_mod", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("base_stats_mod_crit_bonus", "_basics/base_stats_mod_crit_bonus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("base_stats_mod_block_bonus", "_basics/base_stats_mod_block_bonus", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_1_STR_modifier_stack", "_modifiers/_1_STR_modifier_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_1_AGI_modifier_stack", "_modifiers/_1_AGI_modifier_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_1_INT_modifier_stack", "_modifiers/_1_INT_modifier_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_1_CON_modifier_stack", "_modifiers/_1_CON_modifier_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_2_DEX_modifier_stack", "_modifiers/_2_DEX_modifier_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_2_DEF_modifier_stack", "_modifiers/_2_DEF_modifier_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_2_RES_modifier_stack", "_modifiers/_2_RES_modifier_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_2_REC_modifier_stack", "_modifiers/_2_REC_modifier_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_2_LCK_modifier_stack", "_modifiers/_2_LCK_modifier_stack", LUA_MODIFIER_MOTION_NONE)
LinkLuaModifier("_2_MND_modifier_stack", "_modifiers/_2_MND_modifier_stack", LUA_MODIFIER_MOTION_NONE)

---- INIT
	-- ABILITY FUNCTIONS
		function base_stats:GetIntrinsicModifierName()
			return "base_stats_mod"
		end

		function base_stats:Spawn()
			if IsServer() then
        self.max_level = 30
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
				if caster:IsIllusion() then return end
				if caster:IsHero() == false then return end

        if caster:GetLevel() % 3 == 0 then
          self:IncrementSpenderPoints(3, 2)
        end

				--for _, stat in pairs(self.stats_primary) do
					--self:ApplyBonusLevel(stat, self.bonus_level[stat])
				--end

        -- if caster:GetLevel() % 5 == 0 then
        --   if caster:GetLevel() ~= 15 and caster:GetLevel() ~= 30 then
        --     self:ApplyBonusTeam(1)
        --   end
        -- end
			end
		end

    function base_stats:OnAbilityUpgrade(ability)
      self:AddManaExtra(ability)
    end

    function base_stats:AddManaExtra(ability)
      local caster = self:GetCaster()
      if caster:IsHero() == false then return end

      local hero_name = GetHeroName(self:GetCaster():GetUnitName())
      local hero_team = GetHeroTeam(self:GetCaster():GetUnitName())
      local abilities_data = LoadKeyValues("scripts/vscripts/heroes/"..hero_team.."/"..hero_name.."/"..hero_name..".txt")
      if abilities_data == nil then return end

      for ability_name, data in pairs(abilities_data) do
        if ability:GetAbilityName() == ability_name then
          for key, value in pairs(data) do
            if key == "ActiveSpell" then
              if tonumber(value) == 1 then
                self:UpgradeAbility(true)
              end
            end
          end          
        end
      end
    end

	-- LOAD STATS
		function base_stats:ResetAllStats()
			if IsServer() then
				self.primary_points = 0
				self.secondary_points = 0

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

        local index = 1
				for _, stat in pairs(self.stats_primary) do
					self.stat_base[stat] = 0
					self.stat_bonus[stat] = 0
					self.stat_total[stat] = 0
					self.stat_percent[stat] = 0
					self.stat_sub_level[stat] = 0
					self.stat_fraction["level_up"][stat] = {}
					self.stat_fraction["plus_up"][stat] = {}
          index = index + 1
          self:UpdatePanoramaStat(stat)
				end

				for _, stat in pairs(self.stats_secondary) do
					self.stat_base[stat] = 0
					self.stat_bonus[stat] = 0
					self.stat_total[stat] = 0
					self.stat_percent[stat] = 0
					self.stat_sub_level[stat] = 0
					self.stat_fraction["level_up"][stat] = {}
					self.stat_fraction["plus_up"][stat] = {}
          index = index + 1
          self:UpdatePanoramaStat(stat)
				end


        for type, table in pairs(self.stat_fraction) do
          self.stat_fraction[type]["STR"] = {["value"] = 0, "DEF", "MND", "LCK"}
          self.stat_fraction[type]["AGI"] = {["value"] = 0, "DEX", "REC", "LCK"}
          self.stat_fraction[type]["INT"] = {["value"] = 0, "MND", "REC", "RES"}
          self.stat_fraction[type]["CON"] = {["value"] = 0, "DEF", "DEX", "RES"}
          self.stat_fraction[type]["DEX"] = {["value"] = 0, "AGI", "CON"}
          self.stat_fraction[type]["DEF"] = {["value"] = 0, "CON", "STR"}
          self.stat_fraction[type]["RES"] = {["value"] = 0, "INT", "CON"}
          self.stat_fraction[type]["REC"] = {["value"] = 0, "AGI", "INT"}
          self.stat_fraction[type]["LCK"] = {["value"] = 0, "AGI", "STR"}
          self.stat_fraction[type]["MND"] = {["value"] = 0, "INT", "STR"}          
        end
			end
		end

		function base_stats:AddBaseStatsPoints()
			if not IsServer() then return end

      local caster = self:GetCaster()
      local unit_stats = nil
      local heroes_name_data = LoadKeyValues("scripts/kv/heroes_name.kv")
      local heroes_stats_data = LoadKeyValues("scripts/kv/heroes_stats.kv")
      local boss_list = LoadKeyValues("scripts/vscripts/_bosses/_bosses_units.txt")
      local neutral_list = LoadKeyValues("scripts/vscripts/_neutrals/_neutrals_units.txt")
      local summon_list = LoadKeyValues("scripts/npc/npc_units_custom.txt")

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

      if unit_stats == nil then
        for name, table in pairs(summon_list) do
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
        for stat, value in pairs(unit_stats) do
          self.stat_base[stat] = self.stat_base[stat] + value
          self:CalculateStats(0, 0, stat)
          -- for stat_type, value in pairs(stats_type) do
          --   if stat_type == "initial" then
          --     self.stat_base[stat] = self.stat_base[stat] + value
          --     self:CalculateStats(0, 0, stat)
          --     self:IncrementFraction("level_up", stat, value * 3, 0)
          --   elseif stat_type == "bonus_level" then
          --     self.bonus_level[stat] = value
          --   end
          -- end
        end
      else
        for stat, value in pairs(unit_stats) do
          self.stat_base[stat] = self.stat_base[stat] + value
          self:CalculateStats(0, 0, stat)
          self:IncrementFraction("level_up", stat, value * 3, 0)
        end
      end

      self.hero_team_number = caster:GetTeamNumber()

      --self:ApplyBonusTeam(4)
		end

    function base_stats:ApplyBonusTeam(amount)
      if self.hero_team_number == DOTA_TEAM_CUSTOM_1 then
        self.stat_bonus["STR"] = self.stat_bonus["STR"] + amount
        self:CalculateStats(0, 0, "STR")
        self.stat_bonus["AGI"] = self.stat_bonus["AGI"] + amount
        self:CalculateStats(0, 0, "AGI")
        self.stat_bonus["LCK"] = self.stat_bonus["LCK"] + amount
        self:CalculateStats(0, 0, "LCK")
        self.stat_bonus["DEF"] = self.stat_bonus["DEF"] + amount
        self:CalculateStats(0, 0, "DEF")
        self.stat_bonus["DEX"] = self.stat_bonus["DEX"] + amount
        self:CalculateStats(0, 0, "DEX")
      end
      if self.hero_team_number == DOTA_TEAM_CUSTOM_2 then
        self.stat_bonus["INT"] = self.stat_bonus["INT"] + amount
        self:CalculateStats(0, 0, "INT")
        self.stat_bonus["CON"] = self.stat_bonus["CON"] + amount
        self:CalculateStats(0, 0, "CON")
        self.stat_bonus["MND"] = self.stat_bonus["MND"] + amount
        self:CalculateStats(0, 0, "MND")
        self.stat_bonus["REC"] = self.stat_bonus["REC"] + amount
        self:CalculateStats(0, 0, "REC")
        self.stat_bonus["DEX"] = self.stat_bonus["DEX"] + amount
        self:CalculateStats(0, 0, "DEX")
      end
      if self.hero_team_number == DOTA_TEAM_CUSTOM_3 then
        self.stat_bonus["INT"] = self.stat_bonus["INT"] + amount
        self:CalculateStats(0, 0, "INT")
        self.stat_bonus["AGI"] = self.stat_bonus["AGI"] + amount
        self:CalculateStats(0, 0, "AGI")
        self.stat_bonus["REC"] = self.stat_bonus["REC"] + amount
        self:CalculateStats(0, 0, "REC")
        self.stat_bonus["RES"] = self.stat_bonus["RES"] + amount
        self:CalculateStats(0, 0, "RES")
        self.stat_bonus["LCK"] = self.stat_bonus["LCK"] + amount
        self:CalculateStats(0, 0, "LCK")
      end
      if self.hero_team_number == DOTA_TEAM_CUSTOM_4 then
        self.stat_bonus["STR"] = self.stat_bonus["STR"] + amount
        self:CalculateStats(0, 0, "STR")
        self.stat_bonus["CON"] = self.stat_bonus["CON"] + amount
        self:CalculateStats(0, 0, "CON")
        self.stat_bonus["DEF"] = self.stat_bonus["DEF"] + amount
        self:CalculateStats(0, 0, "DEF")
        self.stat_bonus["RES"] = self.stat_bonus["RES"] + amount
        self:CalculateStats(0, 0, "RES")
        self.stat_bonus["MND"] = self.stat_bonus["MND"] + amount
        self:CalculateStats(0, 0, "MND")
      end
    end

		function base_stats:LoadSpecialValues()
			if IsServer() then
				-- STR
				self.base_atk_damage = self:GetSpecialValueFor("base_atk_damage")
				self.damage_percent = self:GetSpecialValueFor("damage_percent")
				self.bonus_atk_damage = self:GetSpecialValueFor("bonus_atk_damage")

				-- AGI
				self.base_attack_time = self:GetSpecialValueFor("base_attack_time")
        self.attack_speed = self:GetSpecialValueFor("attack_speed")
				self.movespeed = self:GetSpecialValueFor("movespeed")
				self.base_movespeed = self:GetSpecialValueFor("base_movespeed")
        self.bonus_movespeed = {}

				-- INT
        self.spell_amp = self:GetSpecialValueFor("spell_amp")
        self.heal_power = self:GetSpecialValueFor("heal_power")
				self.mana = self:GetSpecialValueFor("mana")

				-- CON
				self.health_bonus = self:GetSpecialValueFor("health_bonus")
				self.heal_amp = self:GetSpecialValueFor("heal_amp")

				-- DEF
        self.armor = self:GetSpecialValueFor("armor")
        self.block = self:GetSpecialValueFor("block")

        --RES
				self.magic_resist = self:GetSpecialValueFor("magic_resist")
				self.status_resist = self:GetSpecialValueFor("status_resist")

        --DEX
        self.evade = self:GetSpecialValueFor("evade")
				self.health_regen = self:GetSpecialValueFor("health_regen")
				self.hp_regen_state = 1

        --REC
        self.mana_regen = self:GetSpecialValueFor("mana_regen")
				self.mp_regen_state = 1
        self.cooldown = self:GetSpecialValueFor("cooldown")

        --MND
        self.debuff_amp = self:GetSpecialValueFor("debuff_amp")
				self.buff_amp = self:GetSpecialValueFor("buff_amp")

        --LCK
        self.critical_chance = self:GetSpecialValueFor("critical_chance")
				self.critical_damage = self:GetSpecialValueFor("critical_damage")
				self.base_critical_damage = self:GetSpecialValueFor("base_critical_damage")
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
      if value < 0 then value = 0 end
      if value > 50 then value = 50 end
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

-- ATTRIBUTES POINTS
	-- ADD SPENDER POINTS AND UPDATE PANORAMA
		function base_stats:IncrementSpenderPoints(primary_pts, secondary_pts)
			if IsServer() then
				self.primary_points = self.primary_points + primary_pts
				self.secondary_points = self.secondary_points + secondary_pts
				self:UpdatePanoramaPoints("nil")
			end
		end

    function base_stats:UpgradeStat(stat)
      for _,primary in pairs(self.stats_primary) do
        if stat == primary then
          self.primary_points = self.primary_points - 1
          self.stat_base[stat] = self.stat_base[stat] + 1
          self:IncrementFraction("plus_up", primary, 3, 1)
          self:CalculateStats(0, 0, primary)
        end
      end
    
      for _,secondary in pairs(self.stats_secondary) do
        if stat == secondary then
          self.secondary_points = self.secondary_points - 1
          self.stat_base[stat] = self.stat_base[stat] + 1
          self:IncrementFraction("plus_up", secondary, 2, 2)
          self:CalculateStats(0, 0, secondary)
        end
      end
    
      self:UpdatePanoramaPoints(stat)
    end

		function base_stats:UpdatePanoramaStat(stat)
      if self:GetCaster():IsHero() == false then return end
      if self:GetCaster():IsIllusion() then return end
      
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
      if self:GetCaster():IsHero() == false then return end
      if self:GetCaster():IsIllusion() then return end

			if IsServer() then
				local player = self:GetCaster():GetPlayerOwner()
				if (not player) then return end

        local stats = {}
        local stats_fraction = {}

        for _, stat in pairs(self.stats_primary) do
          stats[stat] = self:IsHeroCanLevelUpStat(stat, self.primary_points) == true
          stats_fraction[stat] = self.stat_fraction["plus_up"][stat]["value"] == 4
				end

        for _, stat in pairs(self.stats_secondary) do
          stats[stat] = self:IsHeroCanLevelUpStat(stat, self.secondary_points) == true
          stats_fraction[stat] = self.stat_fraction["plus_up"][stat]["value"] == 3
				end

				CustomGameEventManager:Send_ServerToPlayer(player, "points_state_from_server", {
					primary_points = self.primary_points,
					secondary_points = self.secondary_points,
					stats = stats,
          stats_fraction = stats_fraction,
          upgraded_stat = upgraded_stat
				})
			end
		end

    function base_stats:RandomizeStatOption()
      local stats = {}
      local locarr = {}
      local index = 1

      for _, stat in pairs(self.stats_primary) do
        if self:IsHeroCanLevelUpStat(stat, 99) then
          stats[index] = stat
          index = index + 1
        end
      end

      for _, stat in pairs(self.stats_secondary) do
        if self:IsHeroCanLevelUpStat(stat, 99) then
          stats[index] = stat
          index = index + 1
        end
      end

      if self:GetCaster():GetLevel() >= self.max_level - 1 then
        self.random_stats = stats
        return
      end

      while #stats > 4 do
        stats[RandomInt(1, #stats)] = "nil"
        index = 1

        for i = 1, #stats, 1 do
          if stats[i] ~= "nil" then
            locarr[index] = stats[i]
            index = index + 1
          end
        end

        stats = locarr
        locarr = {}
      end

      self.random_stats = stats
		end

	-- APPLY STATS
		function base_stats:AddBonusStat(attacker, ability, bonus_amount, base_amount, duration, string)
			if IsServer() then
				local target = self:GetCaster()
				local stringFormat = string.format("%s_modifier_stack", string)

				return target:AddNewModifier(attacker, ability, stringFormat, {
					duration = duration, stacks = bonus_amount, percent = base_amount
				})
			end
		end

		function base_stats:CalculateStats(bonus_value, base_value, stat)
			if IsServer() then
				self.stat_bonus[stat] = self.stat_bonus[stat] + bonus_value
				self.stat_base[stat] = self.stat_base[stat] + base_value

				self.stat_total[stat] = self.stat_base[stat] + self.stat_bonus[stat]
				if self.stat_total[stat] < 0 then self.stat_total[stat] = 0 end
				if self.stat_total[stat] > 99 then self.stat_total[stat] = 99 end

				if stat == "REC" then
					local channel = self:GetCaster():FindAbilityByName("_channel")
					if channel then channel:SetLevel(self.stat_total["REC"] + 1) end
				end

				local void = self:GetCaster():FindAbilityByName("_void")
				if void then void:SetLevel(1) end

				self:UpdatePanoramaStat(stat)
			end
		end

	-- PASSIVE LEVELUP PTS AND FRACTION CALC
		function base_stats:ApplyBonusLevel(stat, value)
			if IsServer() then
				self.stat_sub_level[stat] = self.stat_sub_level[stat] + value
				if self.stat_sub_level[stat] >= self.max_level then
					self.stat_sub_level[stat] = self.stat_sub_level[stat] - self.max_level
					self.stat_base[stat] = self.stat_base[stat] + 1
					self:IncrementFraction("level_up", stat, 3, 0)
					self:CalculateStats(0, 0, stat)
					self:ApplyBonusLevel(stat, 0)
				end
			end
		end

		function base_stats:IncrementFraction(type, stat, value, group)
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
              if group == 1 then self.primary_points = self.primary_points - levelup end
              if group == 2 then self.secondary_points = self.secondary_points - levelup end
							self.stat_base[stat_fraction] = self.stat_base[stat_fraction] + levelup
							self:CalculateStats(0, 0, stat_fraction)
						end
					end
				end
			end
		end

    function base_stats:IsHeroCanLevelUpStat(stat, points)
      local caster = self:GetCaster()
      local total_cost = 1
      local level_cap = 99
      local level_cap_fraction = 99

      -- for _,stats_secondary in pairs(self.stats_secondary) do
      --   if stats_secondary == stat then
      --     level_cap = 99
      --     level_cap_fraction = caster:GetLevel() + 30         
      --   end
      -- end

      for index, stat_fraction in pairs(self.stat_fraction["plus_up"][stat]) do
        if index ~= "value" then
          if self.stat_base[stat_fraction] >= level_cap_fraction then return false end
          total_cost = total_cost + self:GetSubCost(stat_fraction, self.stats_primary, 4)
          total_cost = total_cost + self:GetSubCost(stat_fraction, self.stats_secondary, 3)
        end
      end

      return (level_cap > self.stat_base[stat]) and (points >= total_cost)
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

-- ATTRIBUTES UTILS
	-- STR

    function base_stats:GetTotalPhysicalDamagePercent()
      return 100 + (self.stat_total["STR"] * self.damage_percent)
    end

    function base_stats:GetBonusAtkDamage()
      return self:GetStatBase("STR") * self.bonus_atk_damage
    end

	-- AGI

    function base_stats:GetBAT()
      local caster = self:GetCaster()
      local amount = self.base_attack_time

      if caster:IsRangedAttacker() then amount = amount + 0.2 end

      local bat_increased = caster:FindAllModifiersByName("_modifier_bat_increased")
      for _,modifier in pairs(bat_increased) do
        amount = amount + (modifier:GetStackCount() * 0.01)
      end

      local bat_decreased = caster:FindAllModifiersByName("_modifier_bat_decreased")
      for _,modifier in pairs(bat_decreased) do
        amount = amount - (modifier:GetStackCount() * 0.01)
      end

      return amount
    end

    function base_stats:GetBaseMS()
      return self.base_movespeed + (self.movespeed * self:GetStatBase("AGI"))
    end

    function base_stats:GetBonusMS()
      local caster = self:GetCaster()
      local amount = 0

      local buff = caster:FindAllModifiersByName("_modifier_movespeed_buff")
      for _,modifier in pairs(buff) do
        amount = amount + modifier:GetStackCount()
      end

      local buff = caster:FindAllModifiersByName("_modifier_permanent_movespeed_buff")
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

      return 1 + (amount * 0.01)
    end

    function base_stats:GetTotalMS()
      local min = 50
      local max = 2000
      local amount = math.floor((self:GetBaseMS() - min) * self:GetPercentMS()) + self:GetBonusMS() + min
      if amount < min then amount = min end
      if amount > max then amount = max end
  
      return amount
    end

	-- INT

    function base_stats:GetTotalMagicalDamagePercent()
      return 100 + (self.stat_total["INT"] * self.spell_amp)
    end

    function base_stats:GetTotalHealPowerPercent()
      return self:GetHealPower() * 100
    end

    function base_stats:GetHealPower()
      local caster = self:GetCaster()
      local total = 1 + (self.stat_total["INT"] * self.heal_power * 0.01)

      local heal_power = caster:FindAllModifiersByName("_modifier_heal_power")
      for _,modifier in pairs(heal_power) do
        total = total + (modifier.amount * 0.01)
      end

      return total
    end

  -- CON

    function base_stats:GetHealAmp()
      local caster = self:GetCaster()
      local total = self.heal_amp * self:GetStatBase("CON")

      local heal_amp = caster:FindAllModifiersByName("_modifier_heal_amp")
      for _,modifier in pairs(heal_amp) do
        total = total + modifier.amount
      end

      return total
    end

  -- DEF

  function base_stats:GetBlockAtkDamage()
    return self:GetStatBase("DEF") * self.block
  end

  -- RES
  
  function base_stats:GetStatusResistPercent()
    if self:GetCaster():IsHero() then return self:GetCaster():GetStatusResistance() * 100 end
    return self:GetStatBase("RES") * self.status_resist
  end

  -- DEX

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

    function base_stats:GetBonusHPRegen()
      return 10 + (self:GetStatBase("DEX") * self.health_regen)
    end

    function base_stats:SetHPRegenState(bool)
      if bool == true then self.hp_regen_state = 1 else self.hp_regen_state = 0 end
    end

  -- REC

    function base_stats:GetBonusMPRegen()
      local caster = self:GetCaster()
      if caster:HasModifier("ancient_u_modifier_passive") then return 0 end

      local mp_regen = 5 + (self.stat_total["REC"] * self.mana_regen)

      local mods = caster:FindAllModifiersByName("_modifier_mana_regen")
      for _,modifier in pairs(mods) do
        mp_regen = mp_regen + (modifier:GetStackCount() * 0.01)
      end

      return mp_regen
    end

    function base_stats:SetMPRegenState(bool)
      if bool == true then self.mp_regen_state = 1 else self.mp_regen_state = 0 end
    end

  -- MND

    function base_stats:GetTotalDebuffAmpPercent()
      local caster = self:GetCaster()
      local percent = 100 + (self.stat_total["MND"] * self.debuff_amp)
      local mods_increase = caster:FindAllModifiersByName("_modifier_debuff_increase")
      for _,modifier in pairs(mods_increase) do
        percent = percent + modifier:GetStackCount()
      end

      return percent
    end

    function base_stats:GetDebuffAmp()
      local caster = self:GetCaster()
      local bonus = self.stat_total["MND"] * self.debuff_amp

      local mods_increase = caster:FindAllModifiersByName("_modifier_debuff_increase")
      for _,modifier in pairs(mods_increase) do
        bonus = bonus + modifier:GetStackCount()
      end

      return bonus * 0.01
    end

    function base_stats:GetTotalBuffAmpPercent()
      return 100 + (self:GetStatBase("MND") * self.buff_amp)
    end

		function base_stats:GetBuffAmp()
			return self:GetStatBase("MND") * self.buff_amp * 0.01
		end

  -- LCK

    function base_stats:GetCriticalChance()
      if self.force_crit_chance then return self.force_crit_chance end
      local caster = self:GetCaster()
      local value = self.stat_total["LCK"] * self.critical_chance

      local calc = (value * 6) / (1 +  (value * 0.06))
      return calc
		end

    function base_stats:SetForceCrit(chance, damage)
			self.force_crit_chance = chance
			self.force_crit_damage = damage
		end

    function base_stats:GetTotalCriticalDamage()
      local caster = self:GetCaster()
      local result = self.force_crit_damage

      if result == nil then
        result = self.base_critical_damage + (self.critical_damage * self:GetStatBase("LCK"))
        result = self:GetBonusCriticalDamage(result)
      end

      return result
		end

    function base_stats:GetBonusCriticalDamage(result)
      local caster = self:GetCaster()
      local crit_damage = caster:FindAllModifiersByName("_modifier_crit_damage")
      for _,modifier in pairs(crit_damage) do
        result = result + modifier.amount
      end
      return result
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