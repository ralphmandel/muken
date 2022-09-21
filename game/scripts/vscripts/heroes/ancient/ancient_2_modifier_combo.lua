ancient_2_modifier_combo = class ({})

function ancient_2_modifier_combo:IsHidden()
    return true
end

function ancient_2_modifier_combo:IsPurgable()
    return false
end

function ancient_2_modifier_combo:IsDebuff()
	return false
end

function ancient_2_modifier_combo:GetPriority()
    return MODIFIER_PRIORITY_SUPER_ULTRA
end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_2_modifier_combo:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.restrict = true
	self.gesture = true
	self.combo = 2

	self.parent:Hold()
	self.ability:DoImpact()
	self:StartIntervalThink(0.5)
end

function ancient_2_modifier_combo:OnRefresh(kv)
end

function ancient_2_modifier_combo:OnRemoved(kv)
	self.parent:FadeGesture(ACT_DOTA_CAST_ABILITY_5)
end

function ancient_2_modifier_combo:OnDestroy(kv)
	local units = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil,
		self.parent:Script_GetAttackRange() + 100,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES, FIND_CLOSEST, false
	)

	for _,unit in pairs(units) do
		self.parent:MoveToTargetToAttack(unit)
		break
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_2_modifier_combo:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = self.restrict,
	}

	return state
end

function ancient_2_modifier_combo:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_EVENT_ON_STATE_CHANGED
	}

	return funcs
end

function ancient_2_modifier_combo:OnOrder(keys)
	if keys.unit == self.parent then self:Destroy() end
end

function ancient_2_modifier_combo:OnStateChanged(keys)
	if keys.unit ~= self.parent then return end
	if self.parent:IsStunned()
	or self.parent:IsHexed()
	or self.parent:IsOutOfGame()
	or self.parent:IsFrozen() then
		self:Destroy()
	end
end

function ancient_2_modifier_combo:OnIntervalThink()
	if self.gesture == true then
		if self.combo < 1 then self:Destroy() return end

		if IsServer() then self.parent:EmitSound("Hero_ElderTitan.PreAttack") end
		self.parent:StartGesture(ACT_DOTA_CAST_ABILITY_5)
		self.gesture = false
		self:StartIntervalThink(0.4)
	else
		self.combo = self.combo - 1
		if self.combo == 0 then self.restrict = false end

		self.ability:DoImpact()
		self.gesture = true
		self:StartIntervalThink(0.5)
	end
end