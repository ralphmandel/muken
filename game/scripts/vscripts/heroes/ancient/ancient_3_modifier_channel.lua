ancient_3_modifier_channel = class ({})

function ancient_3_modifier_channel:IsHidden()
    return true
end

function ancient_3_modifier_channel:IsPurgable()
    return false
end

function ancient_3_modifier_channel:GetPriority()
    return MODIFIER_PRIORITY_SUPER_ULTRA
end

-----------------------------------------------------------

function ancient_3_modifier_channel:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local time = self:GetRemainingTime()
	local think = time - 0.45
	self.pos_delay = 0.65
	self.step = 1

	if IsServer() then
		self.parent:AddNewModifier(self.caster, self.ability, "ancient_3_modifier_hands", {duration = time})
	end

	if think < 0 then
		local rate = 1 / (time / 0.45)
		self.parent:StartGestureWithPlaybackRate(ACT_DOTA_ANCESTRAL_SPIRIT, rate)
		self:StartIntervalThink((self.pos_delay * (time / 0.45)) + time)
		self.step = 2
		return
	end

	self.parent:StartGesture(ACT_DOTA_TELEPORT)
	self:StartIntervalThink(think)
end

function ancient_3_modifier_channel:OnRefresh(kv)
end

function ancient_3_modifier_channel:OnRemoved(kv)
	self.parent:FadeGesture(ACT_DOTA_TELEPORT)
	self.parent:FadeGesture(ACT_DOTA_ANCESTRAL_SPIRIT)
	if IsServer() then
		self.parent:StopSound("Ancient.Aura.Channel")
		self.parent:RemoveModifierByName("ancient_3_modifier_hands")
	end
end

------------------------------------------------------------

function ancient_3_modifier_channel:OnIntervalThink()
	if self.step == 1 then
		self.parent:FadeGesture(ACT_DOTA_TELEPORT)
		self.parent:StartGesture(ACT_DOTA_ANCESTRAL_SPIRIT)
		self:StartIntervalThink(self.pos_delay + 0.45)
		self.step = 2
	else
		self:Destroy()
	end
end

function ancient_3_modifier_channel:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end