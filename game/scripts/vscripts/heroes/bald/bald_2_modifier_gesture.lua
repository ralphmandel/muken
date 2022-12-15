bald_2_modifier_gesture = class({})

function bald_2_modifier_gesture:IsHidden() return true end
function bald_2_modifier_gesture:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_2_modifier_gesture:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.tick = 0.31

	if IsServer() then self:OnIntervalThink() end
end

function bald_2_modifier_gesture:OnRefresh(kv)
end

function bald_2_modifier_gesture:OnRemoved()
	self.parent:FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_2_modifier_gesture:OnIntervalThink()
	if IsServer() then
		self.parent:FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)
		self.parent:StartGestureWithPlaybackRate(ACT_DOTA_GENERIC_CHANNEL_1, 1 / self.tick)
		self:StartIntervalThink(self.tick)
		self.tick = self.tick * 1.03
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------