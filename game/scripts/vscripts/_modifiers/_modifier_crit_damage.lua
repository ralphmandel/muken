_modifier_crit_damage = class({})

--------------------------------------------------------------------------------

function _modifier_crit_damage:IsPurgable()
	return false
end

function _modifier_crit_damage:IsHidden()
	return true
end

function _modifier_crit_damage:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function _modifier_crit_damage:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------

function _modifier_crit_damage:OnCreated(kv)
	if IsServer() then self:SetStackCount(kv.amount) end
end