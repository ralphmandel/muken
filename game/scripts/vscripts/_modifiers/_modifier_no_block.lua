_modifier_no_block = class({})

--------------------------------------------------------------------------------
function _modifier_no_block:IsHidden()
	return false
end

function _modifier_no_block:IsPurgable()
	return true
end

function _modifier_no_block:GetTexture()
	return "_modifier_no_block"
end

function _modifier_no_block:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_no_block:OnCreated( kv )
end

--------------------------------------------------------------------------------

function _modifier_no_block:CheckState()
	local state = {
		[MODIFIER_STATE_BLOCK_DISABLED] = true,
	}

	return state
end

--------------------------------------------------------------------------------

function _modifier_no_block:GetEffectName()
	return "particles/items3_fx/star_emblem.vpcf"
end

function _modifier_no_block:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end