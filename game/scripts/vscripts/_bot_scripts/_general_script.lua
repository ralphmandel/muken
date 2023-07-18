_general_script = class({})

-- CONSTANTS -----------------------------------------------------------

  local lawbreaker = require("_bot_scripts/lawbreaker")
  local fleaman = require("_bot_scripts/fleaman")
  local bloodstained = require("_bot_scripts/bloodstained")
  local bocuse = require("_bot_scripts/bocuse")
  local dasdingo = require("_bot_scripts/dasdingo")
  local genuine = require("_bot_scripts/genuine")
  local icebreaker = require("_bot_scripts/icebreaker")
  local ancient = require("_bot_scripts/ancient")

  local ACTION_REST_WAIT_FULL_HEALTH = 100
  local ACTION_REST_WAIT_FULL_MANA = 101
  local ACTION_REST_CHANGE_TO_AGGRESSIVE = 102

  local ACTION_AGRESSIVE_CHANGE_TO_FLEE = 200
  local ACTION_AGRESSIVE_SWAP_TARGET = 201
  local ACTION_AGRESSIVE_ATTACK_TARGET = 202
  local ACTION_AGRESSIVE_SEEK_TARGET = 203
  local ACTION_AGRESSIVE_FIND_TARGET = 204

  local ACTION_FLEE_CHANGE_TO_REST = 300
  local ACTION_FLEE_CHANGE_TO_AGGRESSIVE = 301
  local ACTION_FLEE_GO_TO_FOUNTAIN = 302

  local ACTION_FLEAMAN_STEAL = 400

  local THINK_INTERVAL_INIT = 75
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
  local FULL_MANA_PERCENT = 100

  local LOCATION_MAIN_ARENA = Vector(0, 0, 0)
  local LIMIT_RANGE = 3600
  local MISSING_MAX_TIME = 5

-- CREATE -----------------------------------------------------------

  function _general_script:IsPurgable() return false end
  function _general_script:IsHidden() return true end
  function _general_script:RemoveOnDeath() return false end

  function _general_script:OnCreated(params)
    if IsServer() then
      self.caster = self:GetCaster()
      self.parent = self:GetParent()

      self.state = BOT_STATE_AGGRESSIVE
      self.interval = THINK_INTERVAL_DEFAULT
      self.low_health = LOW_HEALTH_PERCENT
      self:ResetStateData(BOT_STATE_AGGRESSIVE)

      self.abilityScript = self:LoadHeroActions()
      if self.abilityScript == nil then return end
      self.abilityScript.caster = self.parent

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
      MODIFIER_EVENT_ON_ATTACK_LANDED,
      MODIFIER_EVENT_ON_ABILITY_START
    }

    return funcs
  end

  function _general_script:OnAbilityStart(keys)
    if keys.unit ~= self.parent then return end

    local cast_point = keys.ability:GetCastPoint()

    if keys.ability:GetAbilityName() == "bloodstained_4__tear" then self:ChangeState(BOT_STATE_AGGRESSIVE) end

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

      if current_action == ACTION_REST_WAIT_FULL_HEALTH then
        if self.parent:GetHealthPercent() < FULL_HEALTH_PERCENT then
          self.rested = false
        end
      end

      if current_action == ACTION_REST_WAIT_FULL_MANA then
        if self.parent:GetManaPercent() < FULL_MANA_PERCENT then
          self.rested = false
        end
      end

      if current_action == ACTION_REST_CHANGE_TO_AGGRESSIVE then
        if self.rested == true then
          self:ChangeState(BOT_STATE_AGGRESSIVE)
        else
          self.abilityScript:TrySpell(nil, self.state)
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
        if self.parent:GetHealthPercent() < self.low_health then
          self:ChangeState(BOT_STATE_FLEE)
        end
      end

      if current_action == ACTION_AGRESSIVE_SWAP_TARGET then
        local new_target = nil
        if target_state == TARGET_STATE_VISIBLE then
          if self.attack_target:GetHealthPercent() <= LOW_HEALTH_PERCENT then
            new_target = self.attack_target
          end
        end

        if new_target == nil then
          new_target = self:FindNewTarget(
            self.parent:GetOrigin(), self.parent:GetCurrentVisionRange(), TARGET_PRIORITY_ONLY_HERO,
            FIND_ANY_ORDER, LOW_HEALTH_PERCENT, ""
          )
        end

        local enemies = FindUnitsInRadius(
          self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, self.parent:GetCurrentVisionRange(),
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
                  if mod.target:GetTeamNumber() == self.parent:GetTeamNumber() then
                    new_target = enemy
                  end
                end
              end
            end
          end
        end

        if new_target then
          if new_target ~= self.attack_target then
            self.agressive_loc = LOCATION_MAIN_ARENA
            self.attack_target = new_target            
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

      if current_action == ACTION_AGRESSIVE_FIND_TARGET then
        if target_state == TARGET_STATE_INVALID or target_state == TARGET_STATE_DEAD then
          self.agressive_loc = LOCATION_MAIN_ARENA

          self.attack_target = self:FindNewTarget(
            self.parent:GetOrigin(), self.parent:GetCurrentVisionRange(), TARGET_PRIORITY_HERO,
            FIND_ANY_ORDER, FULL_HEALTH_PERCENT, ""
          )
    
          for _, hero in pairs(HeroList:GetAllHeroes()) do
            if self.attack_target == nil and hero:GetTeamNumber() == self.parent:GetTeamNumber() then
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

  function _general_script:FleeThink()
    for i = 1, #self.FleeActions, 1 do
      if self.state ~= BOT_STATE_FLEE then return end
      local current_action = self.FleeActions[i]

      self:SpecialActions(current_action)

      if current_action == ACTION_FLEE_CHANGE_TO_REST then
        if (GetFountainLoc(self.parent) - self.parent:GetOrigin()):Length2D() < 150 then
          self:ChangeState(BOT_STATE_REST)
        end
      end

      if current_action == ACTION_FLEE_CHANGE_TO_AGGRESSIVE then
        if self.parent:GetHealthPercent() > MID_HEALTH_PERCENT then
          self:ChangeState(BOT_STATE_AGGRESSIVE)
        end
      end

      if current_action == ACTION_FLEE_GO_TO_FOUNTAIN then
        if self.abilityScript:TrySpell(nil, self.state) == false then
          self:MoveBotTo("location", GetFountainLoc(self.parent))
        end
      end
    end
  end

  function _general_script:FarmingThink()
  end

  function _general_script:SpecialActions(current_action)
    if current_action == ACTION_FLEAMAN_STEAL then
      if self:CheckTargetState(self.attack_target) ~= TARGET_STATE_MISSING and self.parent:HasModifier("fleaman_5_modifier_passive") then
        local new_target = true

        if self:CheckTargetState(self.attack_target) == TARGET_STATE_VISIBLE then
          local mod_steal = self.attack_target:FindAllModifiersByName("fleaman_5_modifier_steal")
          if mod_steal then
            if mod_steal:GetStackCount() < mod_steal:GetAbility():GetSpecialValueFor("max_stack") then
              new_target = false
            end
          end
        end

        if new_target == true then
          self.agressive_loc = LOCATION_MAIN_ARENA

          local enemies = FindUnitsInRadius(
            self.parent:GetTeamNumber(), self.parent:GetOrigin(), nil, self.parent:GetCurrentVisionRange(),
            DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
            DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false
          )
      
          for _,enemy in pairs(enemies) do
            if self.parent:CanEntityBeSeenByMyTeam(enemy) == true and self:IsOutOfRange(enemy:GetOrigin()) == false then
              local mod_steal = enemy:FindAllModifiersByName("fleaman_5_modifier_steal")
              if mod_steal then
                if mod_steal:GetStackCount() < mod_steal:GetAbility():GetSpecialValueFor("max_stack") then
                  self.attack_target = enemy
                  break
                end
              else
                self.attack_target = enemy
                break
              end
            end
          end
        end
      end
    end
  end

-- UTIL FUNCTIONS -----------------------------------------------------------

  function _general_script:ChangeState(state)
    if self.state ~= state then self:ResetStateData(self.state) end
    self.state = state
  end

  function _general_script:ResetStateData(state)
    if state == BOT_STATE_AGGRESSIVE then
      self.agressive_loc = LOCATION_MAIN_ARENA
      self.attack_target = nil
      self.target_last_loc = nil
      self.missing_start_time = nil
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
      self.parent:GetTeamNumber(), loc, nil, radius,
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
        self.parent:MoveToPosition(LOCATION_MAIN_ARENA)
      else
        self.parent:MoveToTargetToAttack(handle)
      end
    end

    if command == "location" then
      if (handle - self.parent:GetOrigin()):Length2D() > 100 then
        self.parent:MoveToPosition(handle)
      end
    end
  end

  function _general_script:IsOutOfRange(loc)
    return (LOCATION_MAIN_ARENA - loc):Length2D() > LIMIT_RANGE
  end

-- LOAD HERO DATA -----------------------------------------------------------

  function _general_script:ConsumeAllPoints()
    self:ConsumeAbilityPoint()
    self:ConsumeRankPoint()
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
          if ability:IsTrained() == false then
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

  function base_stats:ConsumeStatPoint()
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
      [1] = ACTION_REST_WAIT_FULL_HEALTH,
      [2] = ACTION_REST_WAIT_FULL_MANA,
      [3] = ACTION_REST_CHANGE_TO_AGGRESSIVE,
    }

    self.AggressiveActions = {
      [1] = ACTION_AGRESSIVE_CHANGE_TO_FLEE,
      [2] = ACTION_AGRESSIVE_SWAP_TARGET,
      [3] = ACTION_AGRESSIVE_ATTACK_TARGET,
      [4] = ACTION_AGRESSIVE_SEEK_TARGET,
      [5] = ACTION_AGRESSIVE_FIND_TARGET,
    }

    self.FleeActions = {
      [1] = ACTION_FLEE_CHANGE_TO_REST,
      [2] = ACTION_FLEE_CHANGE_TO_AGGRESSIVE,
      [3] = ACTION_FLEE_GO_TO_FOUNTAIN,
    }

    if GetHeroName(self.parent:GetUnitName()) == "bloodstained" then
      self.low_health = CUSTOM_HEALTH_PERCENT_BLOODSTAINED
      return bloodstained
    end

    if GetHeroName(self.parent:GetUnitName()) == "fleaman" then
      self.AggressiveActions = {
        [1] = ACTION_AGRESSIVE_CHANGE_TO_FLEE,
        [2] = ACTION_AGRESSIVE_SWAP_TARGET,
        [3] = ACTION_AGRESSIVE_ATTACK_TARGET,
        [4] = ACTION_AGRESSIVE_SEEK_TARGET,
        [5] = ACTION_FLEAMAN_STEAL,
        [6] = ACTION_AGRESSIVE_FIND_TARGET,
      }

      return fleaman
    end

    if GetHeroName(self.parent:GetUnitName()) == "ancient" then
      self.RestActions = {
        [1] = ACTION_REST_WAIT_FULL_HEALTH,
        [2] = ACTION_REST_CHANGE_TO_AGGRESSIVE,
      }
      
      return ancient
    end

    if GetHeroName(self.parent:GetUnitName()) == "lawbreaker" then return lawbreaker end
    if GetHeroName(self.parent:GetUnitName()) == "bocuse" then return bocuse end
    if GetHeroName(self.parent:GetUnitName()) == "dasdingo" then return dasdingo end
    if GetHeroName(self.parent:GetUnitName()) == "genuine" then return genuine end
    if GetHeroName(self.parent:GetUnitName()) == "icebreaker" then return icebreaker end
  end