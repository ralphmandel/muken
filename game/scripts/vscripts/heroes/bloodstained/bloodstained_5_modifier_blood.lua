bloodstained_5_modifier_blood = class({})

function bloodstained_5_modifier_blood:IsHidden()
	return true
end

function bloodstained_5_modifier_blood:IsPurgable()
	return false
end

function bloodstained_5_modifier_blood:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_5_modifier_blood:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local blood_percent = self.ability:GetSpecialValueFor("blood_percent") * 0.01
	self.damage = math.ceil(kv.damage * blood_percent)
end

function bloodstained_5_modifier_blood:OnRefresh(kv)
end

function bloodstained_5_modifier_blood:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------