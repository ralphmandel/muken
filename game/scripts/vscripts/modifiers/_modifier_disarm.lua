_modifier_disarm = class({})

--------------------------------------------------------------------------------
function _modifier_disarm:IsHidden()
	return false
end

function _modifier_disarm:IsPurgable()
	return true
end

function _modifier_disarm:IsDebuff()
	return true
end

function _modifier_disarm:GetTexture()
	return "_modifier_disarm"
end

function _modifier_disarm:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_disarm:OnCreated( kv )
end

--------------------------------------------------------------------------------

function _modifier_disarm:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end

--------------------------------------------------------------------------------

function _modifier_disarm:GetEffectName()
	return "particles/units/heroes/hero_snapfire/hero_snapfire_disarm.vpcf"
end

function _modifier_disarm:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end