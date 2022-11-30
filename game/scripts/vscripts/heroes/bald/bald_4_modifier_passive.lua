bald_4_modifier_passive = class({})

function bald_4_modifier_passive:IsHidden()
	return true
end

function bald_4_modifier_passive:IsPurgable()
	return false
end

function bald_4_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_4_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function bald_4_modifier_passive:OnRefresh(kv)
end

function bald_4_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_4_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_PREDEBUFF_APPLIED
	}

	return funcs
end

function bald_4_modifier_passive:OnPreDebuffApplied(keys)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------