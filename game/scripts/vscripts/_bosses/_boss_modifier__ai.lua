_boss_modifier__ai = class({})

local AI_STATE_IDLE = 0
local AI_STATE_AGGRESSIVE = 1
local AI_STATE_RETURNING = 2

local AI_THINK_INTERVAL = 0.25

function _boss_modifier__ai:IsHidden()
	return true
end

function _boss_modifier__ai:OnCreated(params)
    -- Only do AI on server
    if IsServer() then
        -- Set initial state
        self.state = AI_STATE_IDLE

        -- Store parameters from AI creation:
        -- unit:AddNewModifier(caster, ability, "_boss_modifier__ai", { aggroRange = X, leashRange = Y })
        self.aggroRange = 450
        self.leashRange = 1000

        -- Store unit handle so we don't have to call self:GetParent() every time
        self.unit = self:GetParent() 
        Timers:CreateTimer((0.2), function()
			self.spawnPos = self.unit:GetOrigin()
		end)

        -- Set state -> action mapping
        self.stateActions = {
            [AI_STATE_IDLE] = self.IdleThink,
            [AI_STATE_AGGRESSIVE] = self.AggressiveThink,
            [AI_STATE_RETURNING] = self.ReturningThink,
        }

        -- Start thinking
        self:StartIntervalThink(AI_THINK_INTERVAL)
    end
end

function _boss_modifier__ai:OnIntervalThink()
    -- Execute action corresponding to the current state
    if self.unit:IsDominated() then
      RemoveAllModifiersByNameAndAbility(self.unit, "_modifier_immunity", self:GetAbility())
      RemoveAllModifiersByNameAndAbility(self.unit, "_modifier_movespeed_buff", self:GetAbility())
      return
    end
    
    self.stateActions[self.state](self)    
end

function _boss_modifier__ai:IdleThink()
  RemoveAllModifiersByNameAndAbility(self.unit, "_modifier_movespeed_buff", self:GetAbility())

  if self.idle == nil then self.idle = false end
  if self.idle == false then
    self.unit:Stop()
    self.idle = true
  end

  -- Find any enemy units around the AI unit inside the aggroRange
  local units = FindUnitsInRadius(
    self.unit:GetTeam(), self.unit:GetAbsOrigin(), nil, self.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
    FIND_ANY_ORDER, false
  )

  for _,unit in pairs(units) do
    if unit:IsIllusion() == false then
      self.aggroTarget = unit -- Remember who to attack
      self.unit:MoveToTargetToAttack(self.aggroTarget) --Start attacking
      self.state = AI_STATE_AGGRESSIVE --State transition
      return -- Stop processing this state
    end
  end

  local vector = (Vector(0, 0, 0) - self.unit:GetAbsOrigin()):Normalized()
  self.unit:SetForwardVector(vector)

  if self.unit:GetAggroTarget() ~= nil then
    self.aggroTarget = self.unit:GetAggroTarget()
    self.state = AI_STATE_AGGRESSIVE
    return
  end

  if self.unit:HasModifier("_modifier_immunity") == false then
    self.unit:AddNewModifier(self.unit, self:GetAbility(), "_modifier_immunity", {})
  end
end

function _boss_modifier__ai:AggressiveThink()
  self.idle = false

  if self.aggroTarget == nil then
    self.unit:MoveToPosition(self.spawnPos)
    self.state = AI_STATE_RETURNING
    return
  end

  if IsValidEntity(self.aggroTarget) == false then
    self.unit:MoveToPosition(self.spawnPos)
    self.state = AI_STATE_RETURNING
    return
  end 

  local units = FindUnitsInRadius(self.unit:GetTeam(), self.unit:GetAbsOrigin(), nil,
  self.leashRange, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
  FIND_ANY_ORDER, false)

  for _,unit in pairs(units) do
    local ai = unit:FindModifierByName("_boss_modifier__ai")
    if ai ~= nil then
      if ai.state == AI_STATE_IDLE then
        ai.aggroTarget = self.aggroTarget
        ai.state = AI_STATE_AGGRESSIVE
      end
    end
  end

  -- Check if the unit has walked outside its leash range
  if (self.spawnPos - self.unit:GetAbsOrigin()):Length() > self.leashRange then
    self.unit:MoveToPosition(self.spawnPos) --Move back to the spawnpoint
    self.state = AI_STATE_RETURNING --Transition the state to the 'Returning' state(!)
    return -- Stop processing this state
  end
  
  -- Check if the target has died
  if not self.aggroTarget:IsAlive() then
    self.unit:MoveToPosition(self.spawnPos) --Move back to the spawnpoint
    self.state = AI_STATE_RETURNING --Transition the state to the 'Returning' state(!)
    return -- Stop processing this state
  end

  -- Check if the target is invisible or out of game
  if self.aggroTarget:IsOutOfGame() or self.aggroTarget:IsInvisible() then
    self.unit:MoveToPosition(self.spawnPos) --Move back to the spawnpoint
    self.state = AI_STATE_RETURNING --Transition the state to the 'Returning' state(!)
    return -- Stop processing this state
  end

  if self.unit:GetAggroTarget() ~= nil then
    if self.unit:GetAggroTarget() ~= self.aggroTarget then
      self.aggroTarget = self.unit:GetAggroTarget()
      self.unit:MoveToTargetToAttack(self.aggroTarget)
    end
  end

  RemoveAllModifiersByNameAndAbility(self.unit, "_modifier_movespeed_buff", self:GetAbility())
  RemoveAllModifiersByNameAndAbility(self.unit, "_modifier_immunity", self:GetAbility())
end

function _boss_modifier__ai:ReturningThink()
  -- Check if the AI unit has reached its spawn location yet
  if (self.spawnPos - self.unit:GetAbsOrigin()):Length() < 100 then
    self.state = AI_STATE_IDLE -- Transition the state to the 'Idle' state(!)
    return -- Stop processing this state
  end

  -- If not at return position yet, try to move there again
  self.unit:Purge(false, true, false, true, false)
  self.unit:MoveToPosition(self.spawnPos)
  
  RemoveAllModifiersByNameAndAbility(self.unit, "_modifier_movespeed_buff", self:GetAbility())

  -- Find any enemy units around the AI unit inside the aggroRange
  local units = FindUnitsInRadius(
    self.unit:GetTeam(), self.unit:GetAbsOrigin(), nil, self.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY,
    DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS,
    FIND_ANY_ORDER, false
  )

  for _,unit in pairs(units) do
    if unit:IsIllusion() == false then
      self.aggroTarget = unit -- Remember who to attack
      self.unit:MoveToTargetToAttack(self.aggroTarget) --Start attacking
      self.state = AI_STATE_AGGRESSIVE --State transition
      return -- Stop processing this state
    end
  end

  local vector = (Vector(0, 0, 0) - self.unit:GetAbsOrigin()):Normalized()
  self.unit:SetForwardVector(vector)

  if self.unit:GetAggroTarget() ~= nil then
    self.aggroTarget = self.unit:GetAggroTarget()
    self.state = AI_STATE_AGGRESSIVE
    return
  end

  self.unit:AddNewModifier(self.unit, self:GetAbility(), "_modifier_movespeed_buff", {percent = 250})
end

-----------------------------------------------------------

function _boss_modifier__ai:CheckState()
	local state = {}

    if self.state == AI_STATE_IDLE then
        state = {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
    end

	return state
end

function _boss_modifier__ai:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}

	return funcs
end

function _boss_modifier__ai:OnAttackLanded(keys)
	if keys.attacker ~= self.unit then return end
    local sound = ""
    if self.unit:GetUnitName() == "boss_gorillaz" then sound = "Hero_LoneDruid.TrueForm.Attack" end

	if IsServer() then keys.target:EmitSound(sound) end
end

function _boss_modifier__ai:GetAttackSound(keys)
    return ""
end