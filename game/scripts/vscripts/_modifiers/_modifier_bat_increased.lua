_modifier_bat_increased = class({})

--------------------------------------------------------------------------------

function _modifier_bat_increased:IsPurgable()
	return false
end

function _modifier_bat_increased:IsHidden()
	return true
end

function _modifier_bat_increased:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

function _modifier_bat_increased:RemoveOnDeath()
	return false
end

--------------------------------------------------------------------------------

function _modifier_bat_increased:OnCreated(kv)
	if IsServer() then self:SetStackCount(kv.amount * 100) end
end