striker_6_modifier_sof_effect = class({})

function striker_6_modifier_sof_effect:IsHidden()
	return false
end

function striker_6_modifier_sof_effect:IsPurgable()
	return true
end

function striker_6_modifier_sof_effect:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_6_modifier_sof_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.min_health = 0

	-- UP 6.41
	if self.ability:GetRank(41) then
		self.min_health = 1
	end

	local stats = self.ability:GetSpecialValueFor("stats")
	local luck = -self.ability:GetSpecialValueFor("luck")

	self.ability:AddBonus("_1_CON", self.parent, stats, 0, nil)
	self.ability:AddBonus("_2_DEX", self.parent, stats, 0, nil)
	self.ability:AddBonus("_2_MND", self.parent, stats, 0, nil)
	self.ability:AddBonus("_2_RES", self.parent, stats, 0, nil)
	self.ability:AddBonus("_2_LCK", self.parent, luck, 0, nil)
end

function striker_6_modifier_sof_effect:OnRefresh(kv)
end

function striker_6_modifier_sof_effect:OnRemoved()
	self.ability:RemoveBonus("_1_CON", self.parent)
	self.ability:RemoveBonus("_2_DEX", self.parent)
	self.ability:RemoveBonus("_2_MND", self.parent)
	self.ability:RemoveBonus("_2_RES", self.parent)
	self.ability:RemoveBonus("_2_LCK", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function striker_6_modifier_sof_effect:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MIN_HEALTH
	}

	return funcs
end

function striker_6_modifier_sof_effect:GetMinHealth(keys)
	return self.min_health
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function striker_6_modifier_sof_effect:GetEffectName()
	return "particles/striker/ein_sof/striker_ein_sof_2_buff.vpcf"
end

function striker_6_modifier_sof_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end