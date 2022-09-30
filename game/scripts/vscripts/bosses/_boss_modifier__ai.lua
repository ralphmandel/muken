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
        self.aggroRange = 400
        self.leashRange = 1200
        self.no_miss = false

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
    if self.unit:IsDominated() then return end
    self.stateActions[self.state](self)    
end

function _boss_modifier__ai:IdleThink()
    -- Find any enemy units around the AI unit inside the aggroRange
    local units = FindUnitsInRadius(self.unit:GetTeam(), self.unit:GetAbsOrigin(), nil,
        self.aggroRange, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_FOW_VISIBLE + DOTA_UNIT_TARGET_FLAG_NO_INVIS, 
        FIND_ANY_ORDER, false)

    for _,unit in pairs(units) do
        if unit:IsIllusion() == false then
            self.aggroTarget = unit -- Remember who to attack
            self.unit:MoveToTargetToAttack(self.aggroTarget) --Start attacking
            self.state = AI_STATE_AGGRESSIVE --State transition
            return -- Stop processing this state
        end
    end

    -- If one or more units were found, start attacking the first one
    -- if #units > 0 then
    --     --self.spawnPos = self.unit:GetAbsOrigin() -- Remember position to return to
    --     self.aggroTarget = units[1] -- Remember who to attack
    --     self.unit:MoveToTargetToAttack(self.aggroTarget) --Start attacking
    --     self.state = AI_STATE_AGGRESSIVE --State transition
    --     return -- Stop processing this state
    -- end



    if self.unit:GetAggroTarget() ~= nil then
        self.aggroTarget = self.unit:GetAggroTarget()
        self.state = AI_STATE_AGGRESSIVE
        return
    end

    --self.unit:Heal(self.unit:GetBaseMaxHealth() * 0.025, nil)
    -- Nothing else to do in Idle state
end

function _boss_modifier__ai:AggressiveThink()
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
end

function _boss_modifier__ai:ReturningThink()
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

function _boss_modifier__ai:CheckState()
	local state = {}

    if self.no_miss == true then
        state = {[MODIFIER_STATE_CANNOT_MISS] = true}
    end

    if self.state == AI_STATE_IDLE then
        state = {[MODIFIER_STATE_MAGIC_IMMUNE] = true}
    end

	return state
end

function _boss_modifier__ai:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_PRE_ATTACK,
        MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_TRANSLATE_ATTACK_SOUND,
        MODIFIER_EVENT_ON_HEAL_RECEIVED,
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function _boss_modifier__ai:GetModifierPreAttack()
	self.no_miss = (RandomInt(1, 100) <= 40)
end

function _boss_modifier__ai:GetModifierIncomingDamage_Percentage(keys)
    if self.unit:IsDominated() then return 0 end
    if keys.attacker:IsBaseNPC() == false then return -50 end
    if keys.attacker:IsHero() and keys.attacker:IsIllusion() == false then return 0 end
    return -50
end

function _boss_modifier__ai:OnAttackLanded(keys)
	if keys.attacker ~= self.unit then return end
    local sound = ""
    if self.unit:GetUnitName() == "boss_gorillaz" then sound = "Hero_LoneDruid.TrueForm.Attack" end

	if IsServer() then self.unit:EmitSound(sound) end
end

function _boss_modifier__ai:GetAttackSound(keys)
    return ""
end

function _boss_modifier__ai:OnHealReceived(keys)
    if keys.unit ~= self.unit then return end
    if keys.inflictor == nil then return end
    if keys.gain < 1 then return end

    SendOverheadEventMessage(nil, OVERHEAD_ALERT_HEAL, keys.unit, keys.gain, keys.unit)
end

function _boss_modifier__ai:OnTakeDamage(keys)
    if keys.unit ~= self.unit then return end
    if keys.damage_category == DOTA_DAMAGE_CATEGORY_ATTACK then return end

    local efx = nil
    --if keys.damage_type == DAMAGE_TYPE_PHYSICAL then efx = OVERHEAD_ALERT_DAMAGE end
    if keys.damage_type == DAMAGE_TYPE_MAGICAL then efx = OVERHEAD_ALERT_BONUS_SPELL_DAMAGE end

    if keys.inflictor:GetClassname() == "ability_lua" then
        if keys.inflictor:GetAbilityName() == "shadow_0__toxin"
        or keys.inflictor:GetAbilityName() == "osiris_1__poison"
        or keys.inflictor:GetAbilityName() == "dasdingo_4__tribal" then
            efx = OVERHEAD_ALERT_BONUS_POISON_DAMAGE
        end

        if keys.inflictor:GetAbilityName() == "bloodstained_4__frenzy" then
            return
        end
    end

    if keys.damage_type == DAMAGE_TYPE_PURE then self:PopupCustom(math.floor(keys.damage), Vector(255, 225, 175)) end

    if efx == nil then return end
    SendOverheadEventMessage(nil, efx, self.unit, keys.damage, self.unit)
end

-------------------------------------------------------------

function _boss_modifier__ai:PopupCustom(damage, color)
	local pidx = ParticleManager:CreateParticle("particles/msg_fx/msg_crit.vpcf", PATTACH_ABSORIGIN_FOLLOW, self.unit)
    local digits = 1
	if damage < 10 then digits = 2 end
    if damage > 9 and damage < 100 then digits = 3 end
    if damage > 99 and damage < 1000 then digits = 4 end
    if damage > 999 then digits = 5 end

    ParticleManager:SetParticleControl(pidx, 1, Vector(0, damage, 6))
    ParticleManager:SetParticleControl(pidx, 2, Vector(3, digits, 0))
    ParticleManager:SetParticleControl(pidx, 3, color)
end