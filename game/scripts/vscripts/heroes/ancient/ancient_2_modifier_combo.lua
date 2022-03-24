ancient_2_modifier_combo = class ({})

function ancient_2_modifier_combo:IsHidden()
    return true
end

function ancient_2_modifier_combo:IsPurgable()
    return false
end

function ancient_2_modifier_combo:GetPriority()
    return MODIFIER_PRIORITY_ULTRA
end

-----------------------------------------------------------

function ancient_2_modifier_combo:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.gesture = true
	self.combo = 2

	self.ability:DoImpact()
	self:StartIntervalThink(0.5)
end

function ancient_2_modifier_combo:OnRefresh(kv)
end

function ancient_2_modifier_combo:OnRemoved(kv)
	self.parent:FadeGesture(ACT_DOTA_CAST_ABILITY_5)
end

function ancient_2_modifier_combo:OnDestroy(kv)
	local berserk = self.parent:FindAbilityByName("ancient_1__berserk")
	if berserk then self.parent:MoveToTargetToAttack(berserk.attack_target) end
end

------------------------------------------------------------

function ancient_2_modifier_combo:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}

	return state
end

function ancient_2_modifier_combo:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_STATE_CHANGED
	}

	return funcs
end

function ancient_2_modifier_combo:OnStateChanged(keys)
	if keys.unit ~= self.parent then return end
	if self.parent:IsStunned()
	or self.parent:IsOutOfGame()
	or self.parent:IsFrozen() then
		self:Destroy()
	end
end

function ancient_2_modifier_combo:OnIntervalThink()
	if self.gesture == true then
		if self.combo < 1 then self:Destroy() return end

		self.parent:StartGesture(ACT_DOTA_CAST_ABILITY_5)
		self.gesture = false
		self:StartIntervalThink(0.4)
	else
		self.combo = self.combo - 1

		self.ability:DoImpact()
		self.gesture = true
		self:StartIntervalThink(0.5)
	end
end