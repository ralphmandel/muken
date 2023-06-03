_modifier_movespeed_buff = class({})

--------------------------------------------------------------------------------
function _modifier_movespeed_buff:IsPurgable()
	return false
end

function _modifier_movespeed_buff:IsHidden()
	return false
end

function _modifier_movespeed_buff:GetTexture()
	return "_modifier_movespeed_buff"
end

function _modifier_movespeed_buff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
--------------------------------------------------------------------------------

function _modifier_movespeed_buff:OnCreated( kv )
	self.percent = kv.percent

	if IsServer() then self:SetStackCount(self.percent) end
end

--------------------------------------------------------------------------------
-- function _modifier_movespeed_buff:DeclareFunctions()
-- 	local funcs = {
-- 		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
-- 		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE
-- 	}

-- 	return funcs
-- end

-- function _modifier_movespeed_buff:GetModifierMoveSpeedBonus_Percentage()
-- 	return self.percent
-- end

-- function _modifier_movespeed_buff:GetModifierTurnRate_Percentage()
--     return self.percent
-- end