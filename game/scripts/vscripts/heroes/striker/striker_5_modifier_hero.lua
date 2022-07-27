striker_5_modifier_hero = class({})

function striker_5_modifier_hero:IsHidden()
	return false
end

function striker_5_modifier_hero:IsPurgable()
	return false
end

function striker_5_modifier_hero:IsDebuff()
	if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
		return false
	end

	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_5_modifier_hero:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.clone = nil

	-- UP 5.42
	if self.ability:GetRank(42) then
		local stats = 10
		if self.parent:GetTeamNumber() ~= self.caster:GetTeamNumber() then
			stats = -10
		end

		self.ability:AddBonus("_1_STR", self.parent, stats, 0, nil)
		self.ability:AddBonus("_1_AGI", self.parent, stats, 0, nil)
		self.ability:AddBonus("_1_CON", self.parent, stats, 0, nil)
		self.ability:AddBonus("_1_INT", self.parent, stats, 0, nil)
		self.ability:AddBonus("_2_DEF", self.parent, stats, 0, nil)
		self.ability:AddBonus("_2_DEX", self.parent, stats, 0, nil)
		self.ability:AddBonus("_2_RES", self.parent, stats, 0, nil)
		self.ability:AddBonus("_2_REC", self.parent, stats, 0, nil)
		self.ability:AddBonus("_2_LCK", self.parent, stats, 0, nil)
		self.ability:AddBonus("_2_MND", self.parent, stats, 0, nil)
	end
end

function striker_5_modifier_hero:OnRefresh(kv)
end

function striker_5_modifier_hero:OnRemoved()
	self.ability:RemoveBonus("_1_STR", self.parent)
	self.ability:RemoveBonus("_1_AGI", self.parent)
	self.ability:RemoveBonus("_1_CON", self.parent)
	self.ability:RemoveBonus("_1_INT", self.parent)
	self.ability:RemoveBonus("_2_DEX", self.parent)
	self.ability:RemoveBonus("_2_MND", self.parent)
	self.ability:RemoveBonus("_2_RES", self.parent)
	self.ability:RemoveBonus("_2_LCK", self.parent)
	self.ability:RemoveBonus("_2_DEF", self.parent)
	self.ability:RemoveBonus("_2_REC", self.parent)
	
	-- UP 5.41
	if self.ability:GetRank(41)
	and self.parent:IsAlive() then
		local health = self.parent:GetMaxHealth() * 0.2
		if self.parent:GetTeamNumber() ~= self.caster:GetTeamNumber() then
			health = -health
		end

		self.parent:ModifyHealth(self.parent:GetHealth() + health, self.ability, false, 0)
	end

	if self.clone then
		if IsValidEntity(self.clone) then
			self.clone:RemoveModifierByNameAndCaster("striker_5_modifier_clone", self.caster)
		end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------