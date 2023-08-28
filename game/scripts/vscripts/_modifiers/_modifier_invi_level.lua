_modifier_invi_level = class({})

function _modifier_invi_level:IsHidden()
	return true
end

function _modifier_invi_level:IsPurgable()
	return false
end

function _modifier_invi_level:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-----------------------------------------------------------

function _modifier_invi_level:OnCreated(kv)
  if IsServer() then self:SetStackCount(kv.level * 10) end
end

function _modifier_invi_level:OnRefresh(kv)
end

function _modifier_invi_level:OnRemoved()
end

-----------------------------------------------------------

function _modifier_invi_level:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_INVISIBILITY_LEVEL
	}

	return funcs
end

function _modifier_invi_level:GetModifierInvisibilityLevel()
	return 1
end

-----------------------------------------------------------