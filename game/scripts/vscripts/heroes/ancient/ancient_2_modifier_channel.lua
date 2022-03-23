ancient_2_modifier_channel = class ({})

function ancient_2_modifier_channel:IsHidden()
    return true
end

function ancient_2_modifier_channel:IsPurgable()
    return false
end

function ancient_2_modifier_channel:GetPriority()
    return MODIFIER_PRIORITY_ULTRA
end

-----------------------------------------------------------

function ancient_2_modifier_channel:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local time = self:GetRemainingTime()
	local think = time - 0.4
	self.pos_delay = 0.25
	self.step = 1

	if think < 0 then
		local rate = 1 / (time / 0.4)
		self.parent:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_5, rate)
		self:StartIntervalThink((self.pos_delay * (time / 0.4)) + time)
		self.step = 2
		return
	end

	self.parent:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_5, 0.25)
	self:StartIntervalThink(think)
end

function ancient_2_modifier_channel:OnRefresh(kv)
end

function ancient_2_modifier_channel:OnRemoved(kv)
	self.parent:FadeGesture(ACT_DOTA_CAST_ABILITY_5)
end

------------------------------------------------------------

function ancient_2_modifier_channel:OnIntervalThink()
	if self.step == 1 then
		self.parent:FadeGesture(ACT_DOTA_CAST_ABILITY_5)
		self.parent:StartGesture(ACT_DOTA_CAST_ABILITY_5)
		self:StartIntervalThink(self.pos_delay + 0.4)
		self.step = 2
	else
		self:Destroy()
	end
end

function ancient_2_modifier_channel:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end