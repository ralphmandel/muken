_modifier_movespeed_debuff = class({})

--------------------------------------------------------------------------------
function _modifier_movespeed_debuff:IsPurgable()
	return true
end

function _modifier_movespeed_debuff:IsHidden()
	return false
end

function _modifier_movespeed_debuff:GetTexture()
	return "_modifier_movespeed_debuff"
end

function _modifier_movespeed_debuff:IsDebuff()
	return true
end

function _modifier_movespeed_debuff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_movespeed_debuff:OnCreated(kv)
	self.percent = kv.percent
end

--------------------------------------------------------------------------------

function _modifier_movespeed_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE 
	}

	return funcs
end

function _modifier_movespeed_debuff:GetModifierMoveSpeedBonus_Percentage()
	return -self.percent
end

function _modifier_movespeed_debuff:GetModifierTurnRate_Percentage()
    return -self.percent
end