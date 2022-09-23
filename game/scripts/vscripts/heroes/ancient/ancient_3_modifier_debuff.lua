ancient_3_modifier_debuff = class ({})

function ancient_3_modifier_debuff:IsHidden()
    return false
end

function ancient_3_modifier_debuff:IsPurgable()
    return true
end

function ancient_3_modifier_debuff:IsDebuff()
	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_3_modifier_debuff:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.max_ms = self.ability:GetSpecialValueFor("max_ms")
end

function ancient_3_modifier_debuff:OnRefresh(kv)
end

function ancient_3_modifier_debuff:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_3_modifier_debuff:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_LIMIT
	}
	
	return funcs
end

function ancient_3_modifier_debuff:GetModifierMoveSpeed_Limit()
	return self.max_ms
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function ancient_3_modifier_debuff:GetEffectName()
	return "particles/units/heroes/hero_chen/chen_penitence_debuff.vpcf"
end

function ancient_3_modifier_debuff:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end