_modifier_mana_regen = class({})

--------------------------------------------------------------------------------
function _modifier_mana_regen:IsPurgable()
	return false
end

function _modifier_mana_regen:IsHidden()
	return true
end

function _modifier_mana_regen:GetTexture()
	return "_modifier_mana_regen"
end

function _modifier_mana_regen:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _modifier_mana_regen:OnCreated(kv)
	if IsServer() then self:SetStackCount(kv.amount) end
end