ancient_2_channel_leap = class ({})

function ancient_2_channel_leap:IsHidden()
    return true
end

function ancient_2_channel_leap:IsPurgable()
    return false
end

-----------------------------------------------------------

function ancient_2_channel_leap:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.step = 1
	local time = self:GetRemainingTime()
	local think = time - 0.4

	local rate = 1 / (time / 0.4)
	self.parent:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_5, rate)

	-- if think < 0 then
	-- 	local rate = 1 / (time / 0.4)
	-- 	self.parent:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_5, rate)
	-- end

	-- self.parent:StartGesture(ACT_DOTA_GENERIC_CHANNEL_1)
	-- self:StartIntervalThink(think)
end

function ancient_2_channel_leap:OnRefresh(kv)
end

function ancient_2_channel_leap:OnRemoved(kv)
	if self.ability.interrupt == true then
		self.parent:FadeGesture(ACT_DOTA_CAST_ABILITY_5)
	end

	-- if self.ability.interrupt == true then
	-- 	if self.step == 1 then self.parent:FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1) end
	-- 	if self.step == 2 then self.parent:FadeGesture(ACT_DOTA_CAST_ABILITY_5) end
	-- end
end

------------------------------------------------------------

-- function ancient_2_channel_leap:OnIntervalThink()
-- 	self.step = 2
-- 	self.parent:FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)
-- 	self.parent:StartGesture(ACT_DOTA_CAST_ABILITY_5)
-- end