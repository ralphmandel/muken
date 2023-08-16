_general_script = class({})

-- CONSTANTS -----------------------------------------------------------

  local lawbreaker = require("_bot_scripts/lawbreaker")
  local fleaman = require("_bot_scripts/fleaman")
  local bloodstained = require("_bot_scripts/bloodstained")
  local bocuse = require("_bot_scripts/bocuse")

  local dasdingo = require("_bot_scripts/dasdingo")
  local hunter = require("_bot_scripts/hunter")

  local genuine = require("_bot_scripts/genuine")
  local icebreaker = require("_bot_scripts/icebreaker")
  
  local ancient = require("_bot_scripts/ancient")
  local paladin = require("_bot_scripts/paladin")
  local templar = require("_bot_scripts/templar")
  local baldur = require("_bot_scripts/baldur")

  local ACTION_REST_WAIT_FOR_ALLIES = 100
  local ACTION_REST_CHANGE_TO_AGGRESSIVE = 101

  local ACTION_AGRESSIVE_CHANGE_TO_FLEE = 200
  local ACTION_AGRESSIVE_SWAP_TARGET = 201
  local ACTION_AGRESSIVE_ATTACK_TARGET = 202
  local ACTION_AGRESSIVE_SEEK_TARGET = 203
  local ACTION_AGRESSIVE_FIND_TARGET = 204

  local ACTION_FLEE_CHANGE_TO_AGGRESSIVE = 300
  local ACTION_FLEE_GO_TO_FOUNTAIN = 301

  local ACTION_FLEAMAN_STEAL = 400

  local THINK_INTERVAL_INIT = PRE_GAME_TIME
  local THINK_INTERVAL_DEFAULT = 0.25

  local TARGET_STATE_INVALID = 0
  local TARGET_STATE_DEAD = 1
  local TARGET_STATE_MISSING = 2
  local TARGET_STATE_VISIBLE = 3

  local TARGET_PRIORITY_ANY = 0
  local TARGET_PRIORITY_ONLY_HERO = 1
  local TARGET_PRIORITY_HERO = 2
  local TARGET_PRIORITY_UNITS = 3
  local TARGET_PRIORITY_NEUTRALS = 4

  local LOW_HEALTH_PERCENT = 25
  local MID_HEALTH_PERCENT = 50
  local FULL_HEALTH_PERCENT = 100
  local CUSTOM_HEALTH_PERCENT_BLOODSTAINED = 15
  local CUSTOM_HEALTH_PERCENT_BALDUR = 20
  local LOW_MANA_PERCENT = 15
  local MID_MANA_PERCENT = 40
  local FULL_MANA_PERCENT = 100
  local CUSTOM_ENERGY_PERCENT = 0

  local LOCATION_MAIN_ARENA = Vector(0, 0, 0)
  local LIMIT_RANGE = 5000
  local MISSING_MAX_TIME = 5

-- CREATE -----------------------------------------------------------

  function _general_script:IsPurgable() return false end
  function _general_script:IsHidden() return true end
  function _general_script:RemoveOnDeath() return false end

  function _general_script:OnCreated(params)
    if IsServer() then
      self.caster = self:GetCaster()
      self.parent = self:GetParent()
      self.team = self.parent:GetTeamNumber()

      self.state = nil
      self.interval = THINK_INTERVAL_DEFAULT
      self.low_health = LOW_HEALTH_PERCENT
      self.low_mana = LOW_MANA_PERCENT
      self.mid_health = MID_HEALTH_PERCENT
      self.mid_mana = MID_MANA_PERCENT
      self:ChangeState(BOT_STATE_REST)

      self.abilityScript = self:LoadHeroActions()
      if self.abilityScript == nil then return end
      self.abilityScript.caster = self.parent

      self.shrine_target = Entities:FindByClassnameNearest("npc_dota_healer", self.parent:GetOrigin(), 5000)
      self.current_outpost = OUTPOST_ORIGIN[RandomInt(1, 4)]

      self.stateActions = {
        [BOT_STATE_REST] = self.RestThink,
        [BOT_STATE_AGGRESSIVE] = self.AggressiveThink,
        [BOT_STATE_FLEE] = self.FleeThink,
        [BOT_STATE_FARMING] = self.FarmingThink,
      }

      self:StartIntervalThink(THINK_INTERVAL_INIT)
    end
  end

  function _general_script:DeclareFunctions()
    local funcs = {
      MODIFIER_EVENT_ON_DEATH,
      MODIFIER_EVENT_ON_TAKEDAMAGE,
      MODIFIER_EVENT_ON_ABILITY_START
    }

    return funcs
  end

  function _general_script:OnDeath(keys)
    if keys.unit == self.parent then
      self:ChangeState(BOT_STATE_REST)
    end
  end

  function _general_script:OnTakeDamage(keys)
    if keys.unit == self.parent then
      self.take_damage = true
    end
  end

  function _general_script:OnAbilityStart(keys)
    if keys.unit ~= self.parent then return end

    local cast_point = keys.ability:GetCastPoint()

    if IsServer() then
      self:StartIntervalThink(cast_point + 0.5)
    end
  end

  function _general_script:OnIntervalThink()
    self.stateActions[self.state](self)

    if IsServer() then self:StartIntervalThink(self.interval) end
  end

-- STATE FUNCTIONS -----------------------------------------------------------

  function _general_script:RestThink()
    self.rested = true
    for i = 1, #self.RestActions, 1 do
      if self.state ~= BOT_STATE_REST then return end
      local current_action = self.RestActions[i]

      self:SpecialActions(current_action)

      if current_action == ACTION_REST_WAIT_FOR_ALLIES then
        for _, hero in pairs(HeroList:GetAllHeroes()) do
          if hero:GetTeamNumber() == self.team then
            if hero:IsAlive() == false then
              self.rested = false
            end
          end
        end

        if self.parent:IsAlive() and (TEAM_ORIGIN[self.parent:GetTeamNumber()] - self.parent:GetOrigin()):Length2D() > 250 then
          self.rested = true
        end
      end

      if current_action == ACTION_REST_CHANGE_TO_AGGRESSIVE then
        if self.rested == false and self.take_damage == nil then
          self.abilityScript:TrySpell(nil, self.state)
        else
          self:ChangeState(BOT_STATE_AGGRESSIVE)
        end
      end
    end
  end

  function _general_script:AggressiveThink()
    for i = 1, #self.AggressiveActions, 1 do
      if self.state ~= BOT_STATE_AGGRESSIVE then return end
      local current_action = self.AggressiveActions[i]
      local target_state = self:CheckTargetState(self.attack_target)

      if target_state ~= TARGET_STATE_MISSING then
        self.missing_start_time = nil
      end

      self:SpecialActions(current_action)

      if current_action == ACTION_AGRESSIVE_CHANGE_TO_FLEE then
        local new_shrine = self:GetAvailableShrine(self.low_health, self.low_mana)
        if new_shrine then self:ChangeState(BOT_STATE_FLEE) end
      end

      if current_action == ACTION_AGRESSIVE_SWAP_TARGET then
        if target_state == TARGET_STATE_VISIBLE then
          local new_target = nil
          -- LOW HEALTH
            if self.attack_target:GetHealthPercent() <= LOW_HEALTH_PERCENT then
              new_target = self.attack_target
            end
  
            if new_target == nil then
              new_target = self:FindNewTarget(
                self.parent:GetOrigin(), self.parent:GetCurrentVisionRange(), TARGET_PRIORITY_ONLY_HERO,
                FIND_ANY_ORDER, LOW_HEALTH_PERCENT, ""
              )
            end
  
          -- FIND BLOODY ILLUSIONS
            if new_target == nil then
              if self.attack_target:HasModifier("bloodstained__modifier_copy") then
                new_target = self.attack_target
              end
            end
  
            local enemies = FindUnitsInRadius(
              self.team, self.parent:GetOrigin(), nil, self.parent:GetCurrentVisionRange(),
              DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL,
              DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false
            )
      
            for _,enemy in pairs(enemies) do
              if self.parent:CanEntityBeSeenByMyTeam(enemy) == true and new_target == nil
              and self:IsOutOfRange(enemy:GetOrigin()) == false then
                local mod = enemy:FindModifierByName("bloodstained__modifier_copy")
                if mod then
                  if mod.target then
                    if IsValidEntity(mod.target) then
                      if mod.target:GetTeamNumber() == self.team then
                        new_target = enemy
                      end
                    end
                  end
                end
              end
            end
  
          -- FLEAMAN STEAL
            if new_target == nil then
              if self.parent:HasModifier("fleaman_5_modifier_passive") then
                local mod_steal = self.attack_target:FindModifierByName("fleaman_5_modifier_steal")
                if mod_steal then
                  if mod_steal:GetStackCount() < mod_steal:GetAbility():GetSpecialValueFor("max_stack") then
                    new_target = self.attack_target
                  end
                end
              else
                new_target = self.attack_target
              end
            end
  
            local enemies = FindUnitsInRadius(
              self.team, self.parent:GetOrigin(), nil, self.parent:GetCurrentVisionRange(),
              DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
              DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false
            )
        
            for _,enemy in pairs(enemies) do
              if self.parent:CanEntityBeSeenByMyTeam(enemy) == true and new_target == nil
              and self:IsOutOfRange(enemy:GetOrigin()) == false then
                local mod_steal = enemy:FindModifierByName("fleaman_5_modifier_steal")
                if mod_steal then
                  if mod_steal:GetStackCount() < mod_steal:GetAbility():GetSpecialValueFor("max_stack") then
                    new_target = enemy
                  end
                else
                  new_target = enemy
                end
              end
            end
  
          if new_target then
            if new_target ~= self.attack_target then
              self.agressive_loc = self.current_outpost
              self.attack_target = new_target            
            end
          end          
        end
      end

      if current_action == ACTION_AGRESSIVE_ATTACK_TARGET then
        if target_state == TARGET_STATE_VISIBLE then
          self.target_last_loc = self.attack_target:GetOrigin() + (self.parent:GetOrigin() - self.attack_target:GetOrigin()):Normalized() * -200

          if self:IsOutOfRange(self.target_last_loc) then
            self.attack_target = nil
          else
            if self.abilityScript:TrySpell(self.attack_target, self.state) == false then
              self:MoveBotTo("attack_target", self.attack_target)
            end
          end
        end
      end

      if current_action == ACTION_AGRESSIVE_SEEK_TARGET then
        if target_state == TARGET_STATE_MISSING then
          if self.abilityScript:TrySpell(self.target_last_loc, BOT_STATE_AGGRESSIVE_SEEK_TARGET) == false then
            if self.missing_start_time == nil then
              self.missing_start_time = GameRules:GetGameTime()
            end
            if GameRules:GetGameTime() - self.missing_start_time > MISSING_MAX_TIME then
              self.target_last_loc = nil
            end
  
            if self.target_last_loc == nil then
              self.attack_target = nil
            else
              if self:IsOutOfRange(self.target_last_loc) then
                self.attack_target = nil
              end
              if (self.target_last_loc - self.parent:GetOrigin()):Length2D() > 100 then
                self.agressive_loc = self.target_last_loc
                self:MoveBotTo("location", self.agressive_loc)              
              else
                self.target_last_loc = nil
              end
            end
          end
        end
      end

      if current_action == ACTION_AGRESSIVE_FIND_TARGET then
        if target_state == TARGET_STATE_INVALID or target_state == TARGET_STATE_DEAD then
          if self.abilityScript:TrySpell(nil, BOT_STATE_AGGRESSIVE_FIND_TARGET) == false then
            self.agressive_loc = self.current_outpost

            self.attack_target = self:FindNewTarget(
              self.parent:GetOrigin(), 1000, TARGET_PRIORITY_UNITS,
              FIND_ANY_ORDER, FULL_HEALTH_PERCENT, "dasdingo_4_modifier_tribal"
            )

            if self.attack_target == nil then
              self.attack_target = self:FindNewTarget(
                self.parent:GetOrigin(), self.parent:GetCurrentVisionRange(), TARGET_PRIORITY_HERO,
                FIND_ANY_ORDER, FULL_HEALTH_PERCENT, ""
              )              
            end
      
            for _, hero in pairs(HeroList:GetAllHeroes()) do
              if self.attack_target == nil and hero:GetTeamNumber() == self.team then
                self.attack_target = self:FindNewTarget(
                  hero:GetOrigin(), hero:GetCurrentVisionRange(), TARGET_PRIORITY_HERO,
                  FIND_ANY_ORDER, FULL_HEALTH_PERCENT, ""
                )
              end
            end
      
            if self.attack_target == nil then self:MoveBotTo("location", self.agressive_loc) end            
          end
        end
      end
    end
  end

  function _general_script:FleeThink()
    for i = 1, #self.FleeActions, 1 do
      if self.state ~= BOT_STATE_FLEE then return end
      local current_action = self.FleeActions[i]

      self:SpecialActions(current_action)

      if current_action == ACTION_FLEE_CHANGE_TO_AGGRESSIVE then
        if self.parent:GetHealthPercent() >= self.mid_health
        and self.parent:GetManaPercent() >= self.mid_mana
        and self.parent:IsAlive() then
          self:ChangeState(BOT_STATE_AGGRESSIVE)
        end
      end

      if current_action == ACTION_FLEE_GO_TO_FOUNTAIN then
        if self.abilityScript:TrySpell(nil, self.state) == false then
          local new_shrine = self:GetAvailableShrine(self.mid_health, self.mid_mana)

          if new_shrine then
            self.shrine_target = new_shrine
            self:MoveBotTo("npc", self:GetShrineTarget())
          else
            self:ChangeState(BOT_STATE_AGGRESSIVE)
          end
        end
      end
    end
  end

  function _general_script:FarmingThink()
  end

  function _general_script:SpecialActions(current_action)
  end

-- UTIL FUNCTIONS -----------------------------------------------------------

  function _general_script:ChangeState(state)
    if self.state ~= state then self:ResetStateData(self.state) end
    self.state = state
  end

  function _general_script:ResetStateData(state)
    if state == BOT_STATE_AGGRESSIVE then
      self.agressive_loc = self.current_outpost
      self.attack_target = nil
      self.target_last_loc = nil
      self.missing_start_time = nil
    end

    if state == BOT_STATE_REST then
      self.take_damage = nil
    end
  end

  function _general_script:CheckTargetState(target)
    if target == nil then return TARGET_STATE_INVALID end
    if IsValidEntity(target) == false then return TARGET_STATE_INVALID end
    if target:IsAlive() == false then return TARGET_STATE_DEAD end
    if self.parent:CanEntityBeSeenByMyTeam(target) == false then return TARGET_STATE_MISSING end

    return TARGET_STATE_VISIBLE
  end

  function _general_script:FindNewTarget(loc, radius, priority, find_order, hp_cap, modifier_name)
    local enemies = FindUnitsInRadius(
      self.team, loc, nil, radius,
      DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL,
      DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, find_order, false
    )

    for _,enemy in pairs(enemies) do
      if self.parent:CanEntityBeSeenByMyTeam(enemy) == true and self:IsOutOfRange(enemy:GetOrigin()) == false
      and enemy:GetHealthPercent() <= hp_cap and (enemy:HasModifier(modifier_name) or modifier_name == "") then
        if priority == TARGET_PRIORITY_HERO or priority == TARGET_PRIORITY_ONLY_HERO then
          if enemy:IsHero() then return enemy end
        end
        if priority == TARGET_PRIORITY_NEUTRALS then
          if enemy:IsHero() == false and enemy:IsNeutralUnitType() == true then return enemy end
        end
        if priority == TARGET_PRIORITY_UNITS then
          if enemy:IsHero() == false and enemy:IsNeutralUnitType() == false then return enemy end
        end
      end
    end

    for _,enemy in pairs(enemies) do
      if self.parent:CanEntityBeSeenByMyTeam(enemy) == true and self:IsOutOfRange(enemy:GetOrigin()) == false
      and enemy:GetHealthPercent() <= hp_cap and (enemy:HasModifier(modifier_name) or modifier_name == "") then
        if priority ~= TARGET_PRIORITY_ONLY_HERO then
          return enemy
        end
      end
    end
  end

  function _general_script:MoveBotTo(command, handle)
    if self.parent:IsCommandRestricted() then return end
    if handle == nil then return end

    if command == "attack_target" then
      if self:IsOutOfRange(handle:GetOrigin()) then
        self.parent:MoveToPosition(self.current_outpost)
      else
        self.parent:MoveToTargetToAttack(handle)
      end
    end

    if command == "npc" then
      ExecuteOrderFromTable({
        UnitIndex = self.parent:entindex(),
        OrderType = DOTA_UNIT_ORDER_MOVE_TO_TARGET,
        TargetIndex = handle:entindex(),
        --AbilityIndex = self:GetAbility():entindex(),
        Queue = false,
      })
    end

    if command == "location" then
      if handle == self.current_outpost then
        if (handle - self.parent:GetOrigin()):Length2D() < 200 then
          local outpost_list = {}
          local index = 1
          for i = 1, 4 do
            if OUTPOST_ORIGIN[i] ~= self.current_outpost then
              outpost_list[index] = OUTPOST_ORIGIN[i]
              index = index + 1
            end
          end
          self.current_outpost = outpost_list[RandomInt(1, #outpost_list)]
          self.parent:MoveToPosition(self.current_outpost)
        else
          self.parent:MoveToPosition(handle)
        end
      end
      if (handle - self.parent:GetOrigin()):Length2D() > 100 then
        self.parent:MoveToPosition(handle)
      end
    end
  end

  function _general_script:IsOutOfRange(loc)
    return (LOCATION_MAIN_ARENA - loc):Length2D() > LIMIT_RANGE
  end

  function _general_script:GetShrineTarget()
    return self.shrine_target
  end

  function _general_script:GetAvailableShrine(hp_cap, mp_cap)
    local new_shrine = nil
    if self.parent:GetHealthPercent() < hp_cap then
      if self.parent:HasModifier("shrine_refresh_hp_modifier") == false then
        new_shrine = self:FindShrine("hp_filler")
      end
    end

    if new_shrine == nil and self.parent:GetManaPercent() < mp_cap then
      if self.parent:HasModifier("shrine_refresh_mp_modifier") == false then
        new_shrine = self:FindShrine("mp_filler")
      end
    end

    return new_shrine
  end

  function _general_script:FindShrine(shrine_type)
    local shrines = Entities:FindAllByClassname("npc_dota_healer")
    local new_shrine = nil
    local current_distance = 9999

    for _, shrine in pairs(shrines) do
      local filler_ability = shrine:FindAbilityByName("filler_ability")
      local name = string.sub(shrine:GetName(), 1, -3)
      local distance = CalcDistanceBetweenEntityOBB(self.parent, shrine)

      if name == shrine_type and filler_ability:IsCooldownReady() and current_distance > distance then
        current_distance = distance
        new_shrine = shrine
      end
    end

    return new_shrine
  end

-- LOAD HERO DATA -----------------------------------------------------------

  function _general_script:ConsumeAllPoints()
    self:ConsumeAbilityPoint()
    --self:ConsumeRankPoint()
    self:ConsumeStatPoint()
  end

  function _general_script:ConsumeAbilityPoint()
    local base_hero = BaseHero(self.parent)
    local base_stats = BaseStats(self.parent)
    if base_hero == nil or base_stats == nil then return end

    while base_hero.skill_points > 0 do
      local skills_data = LoadKeyValues("scripts/vscripts/heroes/"..GetHeroTeam(self.parent:GetUnitName()).."/"..GetHeroName(self.parent:GetUnitName()).."/"..GetHeroName(self.parent:GetUnitName()).."-skills.txt")
      local available_abilities = {}
      local i = 0
  
      for index, ability_name in pairs(skills_data) do
        local ability = self.parent:FindAbilityByName(ability_name)
        if ability and tonumber(index) < 6 then
          if ability:IsTrained() == false and ability:GetAbilityName() ~= "hunter_4__bandage" then
            i = i + 1
            available_abilities[i] = ability
          end
        end
      end
  
      local ability_result = available_abilities[RandomInt(1, i)]
      ability_result:UpgradeAbility(true)
      base_hero:CheckAbilityPoints(-1)
      base_stats:AddManaExtra(ability_result)
    end
  end

  function _general_script:ConsumeRankPoint()
    local base_hero = BaseHero(self.parent)
    if base_hero == nil then return end
    local result = base_hero:RandomizeRank()

    while result > 0 do
      base_hero:UpgradeRank(result)
      result = base_hero:RandomizeRank()      
    end
  end

  function _general_script:ConsumeStatPoint()
    local base_stats = BaseStats(self.parent)
    if base_stats == nil then return end
    local up = true

    while up == true do
      local main = {}
      local sub = {}
      local data = LoadKeyValues("scripts/kv/heroes_priority.kv")
      up = false
  
      for hero_name, table in pairs(data) do
        if hero_name == GetHeroName(self.parent:GetUnitName()) then
          for group, stats in pairs(table) do
            if group == "MAIN" then
              local index = 1
              for i, stat in pairs(stats) do
                if base_stats:IsHeroCanLevelUpStat(stat, base_stats.primary_points) == true then
                  main[index] = stat
                  index = index + 1
                end
              end
            end
            if group == "SUB" then
              local index = 1
              for i, stat in pairs(stats) do
                if base_stats:IsHeroCanLevelUpStat(stat, base_stats.secondary_points) == true then
                  sub[index] = stat
                  index = index + 1
                end
              end
            end
          end
        end
      end

      if #main > 0 then
        base_stats:UpgradeStat(main[RandomInt(1, #main)])
        up = true
      end

      if #sub > 0 then
        base_stats:UpgradeStat(sub[RandomInt(1, #sub)])
        up = true
      end
    end
  end

  function _general_script:LoadHeroActions()
    self.RestActions = {
      [1] = ACTION_REST_WAIT_FOR_ALLIES,
      [2] = ACTION_REST_CHANGE_TO_AGGRESSIVE,
    }

    self.AggressiveActions = {
      [1] = ACTION_AGRESSIVE_CHANGE_TO_FLEE,
      [2] = ACTION_AGRESSIVE_SWAP_TARGET,
      [3] = ACTION_AGRESSIVE_ATTACK_TARGET,
      [4] = ACTION_AGRESSIVE_SEEK_TARGET,
      [5] = ACTION_AGRESSIVE_FIND_TARGET,
    }

    self.FleeActions = {
      [1] = ACTION_FLEE_CHANGE_TO_AGGRESSIVE,
      [2] = ACTION_FLEE_GO_TO_FOUNTAIN,
    }

    if GetHeroName(self.parent:GetUnitName()) == "bloodstained" then
      self.low_health = CUSTOM_HEALTH_PERCENT_BLOODSTAINED
      return bloodstained
    end

    if GetHeroName(self.parent:GetUnitName()) == "baldur" then
      self.low_health = CUSTOM_HEALTH_PERCENT_BALDUR
      return baldur
    end

    if GetHeroName(self.parent:GetUnitName()) == "ancient" then
      self.low_mana = CUSTOM_ENERGY_PERCENT
      self.mid_mana = CUSTOM_ENERGY_PERCENT
      
      return ancient
    end

    if GetHeroName(self.parent:GetUnitName()) == "lawbreaker" then return lawbreaker end
    if GetHeroName(self.parent:GetUnitName()) == "bocuse" then return bocuse end
    if GetHeroName(self.parent:GetUnitName()) == "fleaman" then return fleaman end
    if GetHeroName(self.parent:GetUnitName()) == "dasdingo" then return dasdingo end
    if GetHeroName(self.parent:GetUnitName()) == "hunter" then return hunter end
    if GetHeroName(self.parent:GetUnitName()) == "genuine" then return genuine end
    if GetHeroName(self.parent:GetUnitName()) == "icebreaker" then return icebreaker end
    if GetHeroName(self.parent:GetUnitName()) == "paladin" then return paladin end
    if GetHeroName(self.parent:GetUnitName()) == "templar" then return templar end
  end