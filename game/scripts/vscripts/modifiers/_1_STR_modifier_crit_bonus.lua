_1_STR_modifier_crit_bonus = class({})

function _1_STR_modifier_crit_bonus:IsPurgable()
	return false
end

function _1_STR_modifier_crit_bonus:IsHidden()
	return true
end

function _1_STR_modifier_crit_bonus:GetAttributes()
	return MODIFIER_ATTRIBUTE_MULTIPLE
end

--------------------------------------------------------------------------------

function _1_STR_modifier_crit_bonus:OnCreated( kv )
	if IsServer() then
		self:SetStackCount(kv.crit_damage)
	end
end

function _1_STR_modifier_crit_bonus:OnRemoved()
end

function _1_STR_modifier_crit_bonus:OnDestroy()
end