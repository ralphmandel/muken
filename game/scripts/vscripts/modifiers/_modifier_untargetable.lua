_modifier_untargetable = class({})

--------------------------------------------------------------------------------
function _modifier_untargetable:IsPurgable()
	return true
end

function _modifier_untargetable:IsHidden()
	return true
end

function _modifier_untargetable:IsDebuff()
	return false
end

function _modifier_untargetable:GetTexture()
	return "_modifier_untargetable"
end

function _modifier_untargetable:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_untargetable:OnCreated( kv )
end

--------------------------------------------------------------------------------

function _modifier_untargetable:CheckState()
	local state = {
	[MODIFIER_STATE_UNTARGETABLE] = true,
	}

	return state
end

--------------------------------------------------------------------------------
