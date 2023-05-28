_modifier_debuff_increase = class({})

--------------------------------------------------------------------------------
function _modifier_debuff_increase:IsPurgable()
	return false
end

function _modifier_debuff_increase:IsHidden()
	return true
end

function _modifier_debuff_increase:GetTexture()
	return "_modifier_debuff_increase"
end

function _modifier_debuff_increase:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_debuff_increase:OnCreated( kv )
	if IsServer() then self:SetStackCount(kv.percent) end
end

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
