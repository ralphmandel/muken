druid_4_modifier_aura_effect = class({})

function druid_4_modifier_aura_effect:IsHidden()
	return false
end

function druid_4_modifier_aura_effect:IsPurgable()
	return false
end

function druid_4_modifier_aura_effect:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_4_modifier_aura_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local stats = self.ability:GetSpecialValueFor("stats")
	self.stats_string = {"_1_STR", "_1_AGI", "_1_CON"}

	-- UP 4.21
	if self.ability:GetRank(21) then
		stats = stats + 5
	end

	for _,string in pairs(self.stats_string) do
		self:IncrementStat(string, stats)
	end
end

function druid_4_modifier_aura_effect:OnRefresh(kv)
end

function druid_4_modifier_aura_effect:OnRemoved()
	for _,string in pairs(self.stats_string) do
		self:DecrementStat(string)
	end
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

function druid_4_modifier_aura_effect:IncrementStat(string, amount)
	self.ability:AddBonus(string, self.parent, amount, 0, nil)
end

function druid_4_modifier_aura_effect:DecrementStat(string)
	self.ability:RemoveBonus(string, self.parent)
end

-- EFFECTS -----------------------------------------------------------

function druid_4_modifier_aura_effect:GetEffectName()
	return "particles/units/heroes/hero_lycan/lycan_howl_buff.vpcf"
end

function druid_4_modifier_aura_effect:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end