_modifier_bkb = class({})

--------------------------------------------------------------------------------
function _modifier_bkb:IsHidden()
	return false
end

function _modifier_bkb:IsPurgable()
	return true
end

function _modifier_bkb:GetTexture()
	return "_modifier_bkb"
end

function _modifier_bkb:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_bkb:OnCreated( kv )
end

--------------------------------------------------------------------------------

function _modifier_bkb:CheckState()
	local state = {
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
	}

	return state
end

--------------------------------------------------------------------------------

function _modifier_bkb:GetEffectName()
	return "particles/items_fx/black_king_bar_avatar.vpcf"
end

function _modifier_bkb:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end