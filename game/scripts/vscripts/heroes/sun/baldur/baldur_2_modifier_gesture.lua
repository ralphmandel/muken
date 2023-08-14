baldur_2_modifier_gesture = class({})

function baldur_2_modifier_gesture:IsHidden() return true end
function baldur_2_modifier_gesture:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function baldur_2_modifier_gesture:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	self.gesture_time = self.ability:GetSpecialValueFor("gesture_time")
	self.gesture_mult = self.ability:GetSpecialValueFor("gesture_mult")

	if IsServer() then self:OnIntervalThink() end
end

function baldur_2_modifier_gesture:OnRefresh(kv)
end

function baldur_2_modifier_gesture:OnRemoved()
	self.parent:FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)
end

-- API FUNCTIONS -----------------------------------------------------------

function baldur_2_modifier_gesture:OnIntervalThink()
	if IsServer() then
		self.parent:FadeGesture(ACT_DOTA_GENERIC_CHANNEL_1)
		self.parent:StartGestureWithPlaybackRate(ACT_DOTA_GENERIC_CHANNEL_1, 1 / self.gesture_time)
		self:StartIntervalThink(self.gesture_time)
		self.gesture_time = self.gesture_time * self.gesture_mult
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------