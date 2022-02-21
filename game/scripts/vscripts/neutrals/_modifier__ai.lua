_modifier__ai = class({})

local AI_STATE_IDLE = 0
local AI_STATE_AGGRESSIVE = 1
local AI_STATE_RETURNING = 2

local AI_THINK_INTERVAL = 0.25

function _modifier__ai:OnCreated(params)
    -- Only do AI on server
    if IsServer() then
        -- Set initial state
        self.state = AI_STATE_IDLE

        -- Store parameters from AI creation:
        -- unit:AddNewModifier(caster, ability, "_modifier__ai", { aggroRange = X, leashRange = Y })
        self.aggroRange = 300
        self.leashRange = 700

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

function _modifier__ai:OnIntervalThink()
    -- Execute action corresponding to the current state
    self.stateActions[self.state](self)    
end

function _modifier__ai:IdleThink()
    -- Find any enemy units around the AI unit inside the aggroRange
    local units = FindUnitsInRadius(self.unit:GetTeam(), self.unit:GetAbsOrigin(), nil,
        self.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
        FIND_ANY_ORDER, false)

    -- If one or more units were found, start attacking the first one
    -- if #units > 0 then
    --     --self.spawnPos = self.unit:GetAbsOrigin() -- Remember position to return to
    --     self.aggroTarget = units[1] -- Remember who to attack
    --     self.unit:MoveToTargetToAttack(self.aggroTarget) --Start attacking
    --     self.state = AI_STATE_AGGRESSIVE --State transition
    --     return -- Stop processing this state
    -- end

	for _,unit in pairs(units) do
		if unit:IsIllusion() == false then
            self.aggroTarget = unit -- Remember who to attack
            self.unit:MoveToTargetToAttack(self.aggroTarget) --Start attacking
            self.state = AI_STATE_AGGRESSIVE --State transition
            return -- Stop processing this state
        end
	end

    if self.unit:GetAggroTarget() ~= nil then
        self.aggroTarget = self.unit:GetAggroTarget()
        self.state = AI_STATE_AGGRESSIVE
        return
    end

    self.unit:Heal(self.unit:GetMaxHealth() * 0.025, self:GetAbility())
    -- Nothing else to do in Idle state
end

function _modifier__ai:AggressiveThink()

    local units = FindUnitsInRadius(self.unit:GetTeam(), self.unit:GetAbsOrigin(), nil,
    self.leashRange, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_NONE, 
    FIND_ANY_ORDER, false)

	for _,unit in pairs(units) do
		local ai = unit:FindModifierByName("_modifier__ai")
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
    
    -- Still in the aggressive state, so do some aggressive stuff.
    self.unit:MoveToTargetToAttack(self.aggroTarget)
end

function _modifier__ai:ReturningThink()
    -- Check if the AI unit has reached its spawn location yet
    if (self.spawnPos - self.unit:GetAbsOrigin()):Length() < 10 then
        self.state = AI_STATE_IDLE -- Transition the state to the 'Idle' state(!)
        return -- Stop processing this state
    end

    -- If not at return position yet, try to move there again
    self.unit:Purge(false, true, false, true, false)
    self.unit:MoveToPosition(self.spawnPos)
end

-----------------------------------------------------------

function _modifier__ai:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND
	}

	return funcs
end

function _modifier__ai:GetModifierIncomingDamage_Percentage(keys)
    if keys.attacker:IsHero() == false then return end
    return -50
end

function _modifier__ai:OnAttackLanded(keys)
	if keys.attacker ~= self:GetParent() then return end
    local sound = ""
    if self:GetParent():GetUnitName() == "neutral_lamp" then sound = "Hero_Spirit_Breaker.Attack" end
    if self:GetParent():GetUnitName() == "neutral_skydragon" then sound = "Hero_Magnataur.Attack" end
    if self:GetParent():GetUnitName() == "neutral_dragon" then sound = "Hero_Magnataur.Attack" end
    if self:GetParent():GetUnitName() == "neutral_igor" then sound = "hero_Crystal.attack" end
    if self:GetParent():GetUnitName() == "neutral_frostbitten" then sound = "Hero_DarkSeer.Attack" end
    if self:GetParent():GetUnitName() == "neutral_crocodile" then sound = "Hero_Slardar.Attack" end
    if self:GetParent():GetUnitName() == "neutral_basic_chameleon" then sound = "Hero_Meepo.Attack" end
    if self:GetParent():GetUnitName() == "neutral_basic_chameleon_b" then sound = "Hero_Meepo.Attack" end
    if self:GetParent():GetUnitName() == "neutral_basic_crocodilian" then sound = "Hero_Slardar.Attack" end
    if self:GetParent():GetUnitName() == "neutral_basic_crocodilian_b" then sound = "Hero_Slardar.Attack" end
    if self:GetParent():GetUnitName() == "neutral_basic_gargoyle" then sound = "Hero_LoneDruid.ProjectileImpact" end
    if self:GetParent():GetUnitName() == "neutral_basic_gargoyle_b" then sound = "Hero_LoneDruid.ProjectileImpact" end

	if IsServer() then self:GetParent():EmitSound(sound) end
end

function _modifier__ai:GetAttackSound(keys)
    return ""
end