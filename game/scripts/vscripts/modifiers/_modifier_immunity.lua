_modifier_immunity = class({})

--------------------------------------------------------------------------------
function _modifier_immunity:IsHidden()
	return false
end

function _modifier_immunity:IsPurgable()
	return true
end

function _modifier_immunity:GetTexture()
	return "_modifier_immunity"
end

function _modifier_immunity:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_immunity:OnCreated( kv )
end

--------------------------------------------------------------------------------

function _modifier_immunity:CheckState()
	local state = {
	[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}

	return state
end

--------------------------------------------------------------------------------

function _modifier_immunity:GetEffectName()
	return "particles/econ/items/omniknight/omni_ti8_head/omniknight_repel_buff_ti8.vpcf"
end

function _modifier_immunity:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end