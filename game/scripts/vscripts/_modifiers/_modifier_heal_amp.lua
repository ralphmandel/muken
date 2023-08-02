_modifier_heal_amp = class({})

--------------------------------------------------------------------------------

function _modifier_heal_amp:IsPurgable()
	return false
end

function _modifier_heal_amp:IsHidden()
	return true
end

function _modifier_heal_amp:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function _modifier_heal_amp:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------

function _modifier_heal_amp:OnCreated(kv)
	if IsServer() then self.amount = kv.amount end
end