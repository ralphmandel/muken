striker_1_modifier_immune = class({})

function striker_1_modifier_immune:IsHidden()
	return true
end

function striker_1_modifier_immune:IsPurgable()
	return false
end

function striker_1_modifier_immune:IsDebuff()
	return false
end

function striker_1_modifier_immune:GetPriority()
	return MODIFIER_PRIORITY_ULTRA
end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_1_modifier_immune:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function striker_1_modifier_immune:OnRefresh(kv)
end

function striker_1_modifier_immune:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

-- function striker_1_modifier_immune:CheckState()
-- 	local state = {
-- 		[MODIFIER_STATE_STUNNED] = false,
-- 		[MODIFIER_STATE_PASSIVES_DISABLED] = false,
-- 		[MODIFIER_STATE_DISARMED] = false
-- 	}

-- 	return state
-- end

function striker_1_modifier_immune:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS
	}

	return funcs
end

function striker_1_modifier_immune:GetModifierAttackRangeBonus(keys)
	return 300
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------