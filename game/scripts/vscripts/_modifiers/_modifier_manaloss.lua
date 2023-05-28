_modifier_manaloss = class({})

--------------------------------------------------------------------------------
function _modifier_manaloss:IsPurgable()
	return true
end

function _modifier_manaloss:IsHidden()
	return false
end

function _modifier_manaloss:GetTexture()
	return "_modifier_manaloss"
end

function _modifier_manaloss:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_manaloss:OnCreated(kv)
	self.manaloss = kv.manaloss

	if IsServer() then self:SetStackCount(self.manaloss) end
end

function _modifier_manaloss:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MANA_REGEN_CONSTANT
	}

	return funcs
end

function _modifier_manaloss:GetModifierConstantManaRegen()
	return -self:GetStackCount()
end