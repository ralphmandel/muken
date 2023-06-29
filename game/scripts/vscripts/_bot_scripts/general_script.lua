general_script = class({})
local lawbreaker = require("_bot_scripts/lawbreaker")
local genuine = require("_bot_scripts/genuine")

local BOT_STATE_IDLE = 0
local BOT_STATE_AGGRESSIVE = 1
local BOT_STATE_FARMING = 2

local INIT_THINK_INTERVAL = 1
local DEFAULT_THINK_INTERVAL = 0.25
local SEARCH_THINK_INTERVAL = 3

local TARGET_STATE_INVALID = 0
local TARGET_STATE_DEAD = 1
local TARGET_STATE_MISSING = 2
local TARGET_STATE_VISIBLE = 3

local TARGET_PRIORITY_ANY = 0
local TARGET_PRIORITY_HERO = 1
local TARGET_PRIORITY_UNITS = 2
local TARGET_PRIORITY_NEUTRALS = 3

local TARGET_HUNTING_MAX_TIME = 15

local LOCATION_MAIN_ARENA = Vector(0, 0, 0)

function general_script:IsPurgable() return false end
function general_script:IsHidden() return true end
function general_script:RemoveOnDeath() return false end

function general_script:OnCreated(params)
  if IsServer() then
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

    self.state = BOT_STATE_AGGRESSIVE
    self.order_point = LOCATION_MAIN_ARENA
    self.attack_target = nil
    self.target_last_loc = nil
    self.hunt_time = nil
    self.interval = INIT_THINK_INTERVAL

    self.abilityScript = self:LoadAbilityScript()
    if self.abilityScript == nil then return end

    self.stateActions = {
      [BOT_STATE_IDLE] = self.IdleThink,
      [BOT_STATE_AGGRESSIVE] = self.AggressiveThink,
      [BOT_STATE_FARMING] = self.FarmingThink,
    }

    self.parent:AddExperience(300, 0, false, false)
    self:StartIntervalThink(self.interval)
  end
end

function general_script:OnIntervalThink()
  self.stateActions[self.state](self)
  self:ConsumeAbilityPoint()

  if IsServer() then self:StartIntervalThink(self.interval) end
end

-- STATE FUNCTIONS -----------------------------------------------------------

function general_script:IdleThink()
end

function general_script:AggressiveThink()
  local target_state = self:CheckTargetState(self.attack_target)

  if target_state ~= TARGET_STATE_MISSING then
    self.order_point = LOCATION_MAIN_ARENA
    self.hunt_time = nil
  end

  if target_state == TARGET_STATE_VISIBLE then
    self.target_last_loc = self.attack_target:GetOrigin()

    if self.abilityScript:TrySpell(self.caster, self.attack_target) == false then
      self:MoveBotTo("attack_target", self.attack_target)
      self.interval = DEFAULT_THINK_INTERVAL
    end

  elseif target_state == TARGET_STATE_MISSING then
    if self.hunt_time == nil then self.hunt_time = GameRules:GetGameTime() end
    self.order_point = self.target_last_loc
    self:MoveBotTo("location", self.order_point)

    if (self.order_point - self.parent:GetOrigin()):Length2D() <= 100
    or GameRules:GetGameTime() - self.hunt_time > TARGET_HUNTING_MAX_TIME then
      self.attack_target = nil
      self.hunt_time = nil
    end
    
    self.interval = DEFAULT_THINK_INTERVAL
    
  else
    self.attack_target = self:FindNewTarget(
      self.parent:GetOrigin(), self.parent:GetCurrentVisionRange(), TARGET_PRIORITY_HERO, FIND_ANY_ORDER
    )
    if self.attack_target == nil then self:MoveBotTo("location", self.order_point) end
    self.interval = DEFAULT_THINK_INTERVAL
  end
end

function general_script:FarmingThink()
end

-- UTIL FUNCTIONS -----------------------------------------------------------

function general_script:CheckTargetState(target)
  if target == nil then return TARGET_STATE_INVALID end
  if IsValidEntity(target) == false then return TARGET_STATE_INVALID end
  if target:IsAlive() == false then return TARGET_STATE_DEAD end
  if self.parent:CanEntityBeSeenByMyTeam(target) == false then return TARGET_STATE_MISSING end

  return TARGET_STATE_VISIBLE
end

function general_script:MoveBotTo(command, handle)
  if self.parent:IsCommandRestricted() then return end
  if handle == nil then return end

  if command == "attack_target" then self.parent:MoveToTargetToAttack(handle) end
  if command == "location" then self.parent:MoveToPosition(handle) end
end

function general_script:FindNewTarget(loc, radius, priority, find_order)
  local enemies = FindUnitsInRadius(
    self.parent:GetTeamNumber(), loc, nil, radius,
    DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL,
    DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, find_order, false
  )

  for _,enemy in pairs(enemies) do
    if self.parent:CanEntityBeSeenByMyTeam(enemy) == true then
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
    if self.parent:CanEntityBeSeenByMyTeam(enemy) == true then
      return enemy
    end
  end
end

function general_script:LoadAbilityScript()
  if GetHeroName(self.parent) == "lawbreaker" then return lawbreaker end
  if GetHeroName(self.parent) == "genuine" then return genuine end
end

function general_script:ConsumeAbilityPoint()
  if BaseHero(self.parent).skill_points <= 0 then return end

  local skills_data = LoadKeyValues("scripts/vscripts/heroes/"..GetHeroTeam(self.parent).."/"..GetHeroName(self.parent).."/"..GetHeroName(self.parent).."-skills.txt")
  local available_abilities = {}
  local i = 1

  for _, ability_name in pairs(skills_data) do
    local ability = self.parent:FindAbilityByName(ability_name)
    if ability then
      if ability:IsTrained() == false
      and self.parent:GetLevel() >= ability:GetHeroLevelRequiredToUpgrade() then
        available_abilities[i] = ability
        i = i + 1
      end
    end
  end

  available_abilities[RandomInt(1, #available_abilities)]:UpgradeAbility(true)
  BaseHero(self.parent):CheckAbilityPoints(-1)
  self:ConsumeAbilityPoint()
end
