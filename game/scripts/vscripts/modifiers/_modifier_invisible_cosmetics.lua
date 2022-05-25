_modifier_invisible_cosmetics = class({})

function _modifier_invisible_cosmetics:IsHidden()
	return true
end

function _modifier_invisible_cosmetics:IsPurgable()
	return false
end

function _modifier_invisible_cosmetics:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

-----------------------------------------------------------

function _modifier_invisible_cosmetics:OnCreated(kv)
end

function _modifier_invisible_cosmetics:OnRefresh(kv)
end

function _modifier_invisible_cosmetics:OnRemoved()
end

-----------------------------------------------------------

function _modifier_invisible_cosmetics:DeclareFunctions()
	local funcs = {
        MODIFIER_PROPERTY_INVISIBILITY_LEVEL
	}

	return funcs
end

function _modifier_invisible_cosmetics:GetModifierInvisibilityLevel()
	return 1
end

-----------------------------------------------------------

function _modifier_invisible_cosmetics:GetEffectName()
	return "particles/units/heroes/hero_phantom_assassin/phantom_assassin_blur.vpcf"
end

function _modifier_invisible_cosmetics:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end