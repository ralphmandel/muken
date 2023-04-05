_modifier_percent_movespeed_debuff = class({})

--------------------------------------------------------------------------------
function _modifier_percent_movespeed_debuff:IsPurgable()
	return true
end

function _modifier_percent_movespeed_debuff:IsHidden()
	return false
end

function _modifier_percent_movespeed_debuff:GetTexture()
	return "_modifier_percent_movespeed_debuff"
end

function _modifier_percent_movespeed_debuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_percent_movespeed_debuff:OnCreated(kv)
	self.percent = kv.percent

	if IsServer() then self:SetStackCount(self.percent) end
end

function _modifier_percent_movespeed_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE 
	}

	return funcs
end

function _modifier_percent_movespeed_debuff:GetModifierTurnRate_Percentage()
  return -self.percent
end