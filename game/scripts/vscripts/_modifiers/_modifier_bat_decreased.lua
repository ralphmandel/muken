_modifier_bat_decreased = class({})

--------------------------------------------------------------------------------

function _modifier_bat_decreased:IsPurgable()
	return false
end

function _modifier_bat_decreased:IsHidden()
	return true
end

function _modifier_bat_decreased:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function _modifier_bat_decreased:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------

function _modifier_bat_decreased:OnCreated(kv)
	if IsServer() then self:SetStackCount(kv.amount * 100) end
end