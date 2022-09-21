osiris_1_modifier_passive = class({})

function osiris_1_modifier_passive:IsHidden()
	return true
end

function osiris_1_modifier_passive:IsPurgable()
	return false
end

function osiris_1_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function osiris_1_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function osiris_1_modifier_passive:OnRefresh(kv)
end

function osiris_1_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function osiris_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function osiris_1_modifier_passive:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end
	if self.parent:PassivesDisabled() then return end

	self.ability:CalcHPLost(keys.damage)
	if IsServer() then self:StartIntervalThink(10) end
end

function osiris_1_modifier_passive:OnIntervalThink()
	self.ability.current_hp = 0
	self:StartIntervalThink(-1)
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------