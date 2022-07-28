krieger_1_modifier_passive = class({})

function krieger_1_modifier_passive:IsHidden()
	return true
end

function krieger_1_modifier_passive:IsPurgable()
	return false
end

function krieger_1_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function krieger_1_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.intervals = 0.2

	self.fury_decrease = self.ability:GetSpecialValueFor("fury_decrease") * self.intervals
	self.hit_gain = self.ability:GetSpecialValueFor("hit_gain")
	self.delay = self.ability:GetSpecialValueFor("delay")
	
	if IsServer() then self:StartIntervalThink(self.intervals) end
end

function krieger_1_modifier_passive:OnRefresh(kv)
end

function krieger_1_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function krieger_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function krieger_1_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if self.parent:PassivesDisabled() then return end

	self:CheckFuryState()
end

function krieger_1_modifier_passive:OnIntervalThink()
	self.ability:ModifyFury(-self.fury_decrease)
	if IsServer() then self:StartIntervalThink(self.intervals) end	
end

-- UTILS -----------------------------------------------------------

function krieger_1_modifier_passive:CheckFuryState()
	if IsServer() then
		local fury_start = self.ability:ModifyFury(self.hit_gain)
		if fury_start then self:StartIntervalThink(self.intervals) return end
		if self.parent:HasModifier("krieger_1_modifier_fury") then return end
	
		self:StartIntervalThink(self.delay)
	end
end

-- EFFECTS -----------------------------------------------------------

function krieger_1_modifier_passive:GetStatusEffectName()
	return "particles/krieger/status_effect_krieger.vpcf"
end

function krieger_1_modifier_passive:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end