_modifier_percent_movespeed_buff = class({})

--------------------------------------------------------------------------------
function _modifier_percent_movespeed_buff:IsPurgable()
	return true
end

function _modifier_percent_movespeed_buff:IsHidden()
	return false
end

function _modifier_percent_movespeed_buff:GetTexture()
	return "_modifier_percent_movespeed_buff"
end

function _modifier_percent_movespeed_buff:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end
--------------------------------------------------------------------------------

function _modifier_percent_movespeed_buff:OnCreated( kv )
	self.percent = kv.percent

	if IsServer() then self:SetStackCount(self.percent) end
end