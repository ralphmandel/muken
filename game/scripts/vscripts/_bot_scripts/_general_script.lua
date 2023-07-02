_general_script = class({})
local lawbreaker = require("_bot_scripts/lawbreaker")
local fleaman = require("_bot_scripts/fleaman")
local bloodstained = require("_bot_scripts/bloodstained")
local bocuse = require("_bot_scripts/bocuse")
local dasdingo = require("_bot_scripts/dasdingo")
local genuine = require("_bot_scripts/genuine")
local icebreaker = require("_bot_scripts/icebreaker")
local ancient = require("_bot_scripts/ancient")

local BOT_STATE_IDLE = 0
local BOT_STATE_AGGRESSIVE = 1
local BOT_STATE_FLEE = 2
local BOT_STATE_FARMING = 3

local THINK_INTERVAL_INIT = 45
local THINK_INTERVAL_DEFAULT = 0.25
local THINK_INTERVAL_SEARCH = 3

local TARGET_STATE_INVALID = 0
local TARGET_STATE_DEAD = 1
local TARGET_STATE_MISSING = 2
local TARGET_STATE_VISIBLE = 3

local TARGET_PRIORITY_ANY = 0
local TARGET_PRIORITY_HERO = 1
local TARGET_PRIORITY_UNITS = 2
local TARGET_PRIORITY_NEUTRALS = 3

local TARGET_HUNTING_MAX_TIME = 5

local LOW_HEALTH_PERCENT = 20

local LOCATION_MAIN_ARENA = Vector(0, 0, 0)
local LIMIT_RANGE = 3600

function _general_script:IsPurgable() return false end
function _general_script:IsHidden() return true end
function _general_script:RemoveOnDeath() return false end

function _general_script:OnCreated(params)
  if IsServer() then
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

    self.state = BOT_STATE_AGGRESSIVE
    self.interval = THINK_INTERVAL_INIT
    self.low_health = LOW_HEALTH_PERCENT
    self:ResetStateData(BOT_STATE_AGGRESSIVE)

    self.abilityScript = self:LoadAbilityScript()
    if self.abilityScript == nil then return end
    self.abilityScript.caster = self.parent

    self.stateActions = {
      [BOT_STATE_IDLE] = self.IdleThink,
      [BOT_STATE_AGGRESSIVE] = self.AggressiveThink,
      [BOT_STATE_FLEE] = self.FleeThink,
      [BOT_STATE_FARMING] = self.FarmingThink,
    }

    self.parent:AddExperience(300, 0, false, false)
    self:StartIntervalThink(self.interval)
  end
end

function _general_script:OnIntervalThink()
  if self.stateActions[self.state](self) then
    self:OnIntervalThink()
    return
  end
  
  self:ConsumeAbilityPoint()
  self:ConsumeStatPoint()

  if IsServer() then self:StartIntervalThink(self.interval) end
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
  self.interval = cast_point + 0.5

  if IsServer() then self:StartIntervalThink(self.interval) end
end

-- STATE FUNCTIONS -----------------------------------------------------------

function _general_script:IdleThink()
end

function _general_script:AggressiveThink()
  if self.parent:GetHealthPercent() < self.low_health then
    self.state = BOT_STATE_FLEE
    self.interval = THINK_INTERVAL_DEFAULT
    self:ResetStateData(BOT_STATE_AGGRESSIVE)
    return true
  end

  if (LOCATION_MAIN_ARENA - self.parent:GetOrigin()):Length2D() > LIMIT_RANGE then
    self.attack_target = nil
    self.interval = THINK_INTERVAL_DEFAULT
  end

  local target_state = self:CheckTargetState(self.attack_target)

  -- CUSTOM ACTION SPECIAL BLOODY TEARS
  if target_state ~= TARGET_STATE_VISIBLE and self.abilityScript.TryCast_Tear then
    if self.abilityScript:TryCast_Tear() == true then return end
  end

  if target_state ~= TARGET_STATE_MISSING then
    self.agressive_loc = LOCATION_MAIN_ARENA
    self.hunt_time = nil
  end

  if target_state == TARGET_STATE_VISIBLE then
    self.target_last_loc = self.attack_target:GetOrigin() + (self.parent:GetOrigin() - self.attack_target:GetOrigin()):Normalized() * -200

    if self.abilityScript:TrySpell(self.attack_target) == false then
      self:MoveBotTo("attack_target", self.attack_target)
      self.interval = THINK_INTERVAL_DEFAULT
    end

  elseif target_state == TARGET_STATE_MISSING then
    if self.hunt_time == nil then self.hunt_time = GameRules:GetGameTime() end
    self.agressive_loc = self.target_last_loc
    self:MoveBotTo("location", self.agressive_loc)

    if GameRules:GetGameTime() - self.hunt_time > TARGET_HUNTING_MAX_TIME then
      self.attack_target = nil
      self.hunt_time = nil
    end
    
    self.interval = THINK_INTERVAL_DEFAULT

  else
    self.attack_target = self:FindNewTarget(
      self.parent:GetOrigin(), self.parent:GetCurrentVisionRange(), TARGET_PRIORITY_HERO, FIND_ANY_ORDER
    )

    for _, hero in pairs(HeroList:GetAllHeroes()) do
      if self.attack_target == nil and hero:GetTeamNumber() == self.parent:GetTeamNumber() then
        self.attack_target = self:FindNewTarget(
          hero:GetOrigin(), hero:GetCurrentVisionRange(), TARGET_PRIORITY_HERO, FIND_ANY_ORDER
        )
      end
    end

    if self.attack_target == nil then self:MoveBotTo("location", self.agressive_loc) end
    
    self.interval = THINK_INTERVAL_DEFAULT
  end
end

function _general_script:FleeThink()
  if self.parent:GetHealthPercent() == 100 then
    self.state = BOT_STATE_AGGRESSIVE
    self.interval = THINK_INTERVAL_DEFAULT
    return true
  end

  self:MoveBotTo("location", GetFountainLoc(self.parent))
end

function _general_script:FarmingThink()
end

-- UTIL FUNCTIONS -----------------------------------------------------------

function _general_script:ResetStateData(state)
  if state == BOT_STATE_AGGRESSIVE then
    self.agressive_loc = LOCATION_MAIN_ARENA
    self.attack_target = nil
    self.target_last_loc = nil
    self.hunt_time = nil
  end
end

function _general_script:CheckTargetState(target)
  if target == nil then return TARGET_STATE_INVALID end
  if IsValidEntity(target) == false then return TARGET_STATE_INVALID end
  if target:IsAlive() == false then return TARGET_STATE_DEAD end
  if self.parent:CanEntityBeSeenByMyTeam(target) == false then return TARGET_STATE_MISSING end

  return TARGET_STATE_VISIBLE
end

function _general_script:FindNewTarget(loc, radius, priority, find_order)
  local enemies = FindUnitsInRadius(
    self.parent:GetTeamNumber(), loc, nil, radius,
    DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL,
    DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, find_order, false
  )

  for _,enemy in pairs(enemies) do
    if self.parent:CanEntityBeSeenByMyTeam(enemy) == true
    and (LOCATION_MAIN_ARENA - enemy:GetOrigin()):Length2D() < LIMIT_RANGE then
      if priority == TARGET_PRIORITY_HERO then
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
    if self.parent:CanEntityBeSeenByMyTeam(enemy) == true
    and (LOCATION_MAIN_ARENA - enemy:GetOrigin()):Length2D() < LIMIT_RANGE then
      return enemy
    end
  end
end

function _general_script:MoveBotTo(command, handle)
  if self.parent:IsCommandRestricted() then return end
  if handle == nil then return end

  if command == "attack_target" then
    if (LOCATION_MAIN_ARENA - handle:GetOrigin()):Length2D() > LIMIT_RANGE then
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

function _general_script:LoadAbilityScript()
  if GetHeroName(self.parent) == "lawbreaker" then return lawbreaker end
  if GetHeroName(self.parent) == "fleaman" then return fleaman end
  if GetHeroName(self.parent) == "bloodstained" then return bloodstained end
  if GetHeroName(self.parent) == "bocuse" then return bocuse end

  if GetHeroName(self.parent) == "dasdingo" then return dasdingo end

  if GetHeroName(self.parent) == "genuine" then return genuine end
  if GetHeroName(self.parent) == "icebreaker" then return icebreaker end

  if GetHeroName(self.parent) == "ancient" then return ancient end
end

function _general_script:ConsumeAbilityPoint()
  local base_hero = BaseHero(self.parent)
  if base_hero == nil then return end
  if base_hero.skill_points <= 0 then return end

  local skills_data = LoadKeyValues("scripts/vscripts/heroes/"..GetHeroTeam(self.parent).."/"..GetHeroName(self.parent).."/"..GetHeroName(self.parent).."-skills.txt")
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

  available_abilities[RandomInt(1, i)]:UpgradeAbility(true)
  base_hero:CheckAbilityPoints(-1)
  self:ConsumeAbilityPoint()
end

function _general_script:ConsumeStatPoint()
  local base_stats = BaseStats(self.parent)
  if base_stats == nil then return end
  if base_stats.random_stats == nil then return end
  if base_stats.total_points <= 0 then return end

  local main_stats = {
    [1] = "STR",
    [2] = "AGI",
    [3] = "INT",
    [4] = "CON",
    [5] = "MND"
  } --MND LCK DEF RES REC DEX

  if GetHeroName(self.parent) == "lawbreaker" then
    main_stats[1] = "STR"
    main_stats[2] = "INT"
    main_stats[3] = "LCK"
    main_stats[4] = "RES"
    main_stats[5] = "DEF"
  end

  if GetHeroName(self.parent) == "fleaman" then
    main_stats[1] = "AGI"
    main_stats[2] = "STR"
    main_stats[3] = "DEX"
    main_stats[4] = "LCK"
    main_stats[5] = "REC"
  end

  if GetHeroName(self.parent) == "bloodstained" then
    main_stats[1] = "STR"
    main_stats[2] = "AGI"
    main_stats[3] = "LCK"
    main_stats[4] = "DEF"
    main_stats[5] = "MND"
  end

  if GetHeroName(self.parent) == "bocuse" then
    main_stats[1] = "STR"
    main_stats[2] = "INT"
    main_stats[3] = "RES"
    main_stats[4] = "MND"
    main_stats[5] = "DEF"
  end

  if GetHeroName(self.parent) == "dasdingo" then
    main_stats[1] = "INT"
    main_stats[2] = "CON"
    main_stats[3] = "MND"
    main_stats[4] = "REC"
    main_stats[5] = "RES"
  end

  if GetHeroName(self.parent) == "genuine" then
    main_stats[1] = "INT"
    main_stats[2] = "AGI"
    main_stats[3] = "REC"
    main_stats[4] = "RES"
    main_stats[5] = "DEX"
  end

  if GetHeroName(self.parent) == "icebreaker" then
    main_stats[1] = "INT"
    main_stats[2] = "AGI"
    main_stats[3] = "DEX"
    main_stats[4] = "REC"
    main_stats[5] = "LCK"
  end

  if GetHeroName(self.parent) == "ancient" then
    main_stats[1] = "STR"
    main_stats[2] = "INT"
    main_stats[3] = "DEF"
    main_stats[4] = "RES"
    main_stats[5] = "LCK"
  end

  local main = 0

  for i = 1, 5, 1 do
    for index, random_stat in pairs(base_stats.random_stats) do
      if main_stats[i] == random_stat and main == 0 then
        main = index
      end
    end
  end

  if main == 0 then main = RandomInt(1, #base_stats.random_stats) end
  base_stats:UpgradeStat(base_stats.random_stats[main])
  self:ConsumeStatPoint()
end