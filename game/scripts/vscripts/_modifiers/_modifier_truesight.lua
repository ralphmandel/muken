_modifier_truesight = class({})

--------------------------------------------------------------------------------

function _modifier_truesight:IsHidden()
	return true
end

function _modifier_truesight:IsPurgable()
	return false
end

function _modifier_truesight:GetTexture()
	return "_modifier_truesight"
end

function _modifier_truesight:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_truesight:OnCreated( kv )
	self.slow = kv.slow or 0
end

--------------------------------------------------------------------------------

function _modifier_truesight:CheckState()

	local state = {
		[MODIFIER_STATE_INVISIBLE] = false,
	}

	return state
end

function _modifier_truesight:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

--------------------------------------------------------------------------------

function _modifier_truesight:DeclareFunctions()

	local funcs

	if self:GetParent():HasModifier("_modifier_invisible") == true then
		funcs = {
			MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		}
	end

	return funcs
end

function _modifier_truesight:GetModifierMoveSpeedBonus_Percentage()
	return -self.slow
end

--------------------------------------------------------------------------------

function _modifier_truesight:GetEffectName()
	return "particles/econ/wards/ti8_ward/ti8_ward_true_sight_ambient.vpcf"
end

function _modifier_truesight:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end