_modifier_heal_decay = class({})

--------------------------------------------------------------------------------

function _modifier_heal_decay:IsPurgable()
	return false
end

function _modifier_heal_decay:IsHidden()
	return true
end

function _modifier_heal_decay:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function _modifier_heal_decay:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------

function _modifier_heal_decay:OnCreated(kv)
	if IsServer() then self.amount = kv.amount end
end