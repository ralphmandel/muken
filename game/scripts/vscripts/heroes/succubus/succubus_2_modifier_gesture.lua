succubus_2_modifier_gesture = class({})

--------------------------------------------------------------------------------

function succubus_2_modifier_gesture:IsHidden()
	return true
end

function succubus_2_modifier_gesture:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function succubus_2_modifier_gesture:OnCreated( kv )
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.parent:StartGestureWithPlaybackRate(ACT_DOTA_LOADOUT, 4.1)
end

function succubus_2_modifier_gesture:OnRefresh( kv )
end

function succubus_2_modifier_gesture:OnRemoved()
self.parent:FadeGesture(ACT_DOTA_LOADOUT)
end

--------------------------------------------------------------------------------
