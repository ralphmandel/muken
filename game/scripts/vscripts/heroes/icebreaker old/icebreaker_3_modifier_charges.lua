icebreaker_3_modifier_charges = class({})

function icebreaker_3_modifier_charges:IsHidden()
	return false
end

function icebreaker_3_modifier_charges:IsPurgable()
    return false
end

--------------------------------------------------------------------------------

function icebreaker_3_modifier_charges:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.ability.charges = self.ability:GetSpecialValueFor("charges")

	if IsServer() then
		self.true_night = true
		self:SetStackCount(self.ability.charges)
		self:StartIntervalThink(FrameTime())
	end
end

function icebreaker_3_modifier_charges:OnRefresh( kv )
end

function icebreaker_3_modifier_charges:OnRemoved()
end

--------------------------------------------------------------------------------

function icebreaker_3_modifier_charges:OnIntervalThink()
	if GameRules:IsDaytime() then
		self.ability:SetActivated(false)
		self.ability:DestroyShard()
		self.true_night = false
	else
		if GameRules:IsTemporaryNight() == false then
			if self.true_night == false then
				self.true_night = true
				self:SetStackCount(self.ability.charges)
			end
		end

		self.ability:SetActivated(self:GetStackCount() > 0)
	end

	self:StartIntervalThink(-1)
	self:StartIntervalThink(FrameTime())
end