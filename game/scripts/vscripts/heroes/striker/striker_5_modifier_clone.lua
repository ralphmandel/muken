striker_5_modifier_clone = class({})

function striker_5_modifier_clone:IsHidden()
	return true
end

function striker_5_modifier_clone:IsPurgable()
	return false
end

function striker_5_modifier_clone:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_5_modifier_clone:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.target = nil

	-- UP 5.11
	if self.ability:GetRank(11) then
		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_buff", {percent = 20})
	end

	-- UP 5.12
	if self.ability:GetRank(12) then
		self.ability:AddBonus("_1_AGI", self.parent, 15, 0, nil)
		self.ability:AddBonus("_1_STR", self.parent, -15, 0, nil)
	end
end

function striker_5_modifier_clone:OnRefresh(kv)
end

function striker_5_modifier_clone:OnRemoved()
	if self.parent:IsAlive() then
		self.parent:Kill(self.ability, self.caster)
	end
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------