_modifier_cosmetics = class({})

--------------------------------------------------------------------------------
function _modifier_cosmetics:IsPurgable()
	return false
end

function _modifier_cosmetics:IsHidden()
	return true
end

function _modifier_cosmetics:IsDebuff()
	return false
end

function _modifier_cosmetics:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_cosmetics:OnCreated( kv )
	self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.model = kv.model

	Timers:CreateTimer((0.2), function()
		self.parent:FollowEntity(self.caster, true)
	end)
end

function _modifier_cosmetics:OnRefresh( kv )
end

function _modifier_cosmetics:OnRemoved()
end

--------------------------------------------------------------------------------

function _modifier_cosmetics:CheckState()
	local state = {
		[MODIFIER_STATE_UNSELECTABLE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}

	return state
end

function _modifier_cosmetics:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MODEL_CHANGE,
		MODIFIER_EVENT_ON_STATE_CHANGED

	}

	return funcs
end

function _modifier_cosmetics:GetModifierModelChange()
	return self.model
end

function _modifier_cosmetics:OnStateChanged(keys)
	if keys.unit ~= self.caster then return end
	if self.caster:IsHexed() or self.caster:IsOutOfGame() then
		self.parent:AddNoDraw()
	else
		self.parent:RemoveNoDraw()
	end
end