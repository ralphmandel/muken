_modifier_no_vision_attacker = class({})

function _modifier_no_vision_attacker:IsHidden()
	return true
end

function _modifier_no_vision_attacker:IsPurgable()
	return false
end

function _modifier_no_vision_attacker:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-----------------------------------------------------------

function _modifier_no_vision_attacker:OnCreated(kv)
end

function _modifier_no_vision_attacker:OnRefresh(kv)
end

function _modifier_no_vision_attacker:OnRemoved()
end

-----------------------------------------------------------

function _modifier_no_vision_attacker:DeclareFunctions()
	local funcs = {
    MODIFIER_PROPERTY_DONT_GIVE_VISION_OF_ATTACKER
	}

	return funcs
end

function _modifier_no_vision_attacker:GetModifierNoVisionOfAttacker(keys)
	return 1
end

-----------------------------------------------------------