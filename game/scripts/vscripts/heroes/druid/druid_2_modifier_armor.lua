druid_2_modifier_armor = class({})

function druid_2_modifier_armor:IsHidden()
	return false
end

function druid_2_modifier_armor:IsPurgable()
	return true
end

function druid_2_modifier_armor:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_2_modifier_armor:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.interval = self.ability:GetSpecialValueFor("interval")
	self.heal = self.ability:GetSpecialValueFor("heal_per_sec") * self.interval
	self:ChangeStats()

	if IsServer() then
		self:StartIntervalThink(self.interval)
		self:PlayEfxStart()
	end
end

function druid_2_modifier_armor:OnRefresh(kv)
end

function druid_2_modifier_armor:OnRemoved()
	self.ability:RemoveBonus("_2_DEX", self.parent)
	self.ability:RemoveBonus("_2_DEF", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_2_modifier_armor:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function druid_2_modifier_armor:OnAttackLanded(keys)
	if keys.target ~= self.parent then return end

	local bonus_per_atk = self.ability:GetSpecialValueFor("bonus_per_atk")
	self:SetDuration(self:GetRemainingTime() + bonus_per_atk, true)
end

function druid_2_modifier_armor:OnIntervalThink()
	local heal = self.heal
	local base_stats = self.caster:FindAbilityByName("base_stats")
	if base_stats then heal = heal * base_stats:GetHealPower() end
	if heal >= 1 then self.parent:Heal(heal, self.ability) end

	if IsServer() then self:StartIntervalThink(self.interval) end
end

-- UTILS -----------------------------------------------------------

function druid_2_modifier_armor:ChangeStats()
	local dex = 0
	local base_stats = self.parent:FindAbilityByName("base_stats")
	if base_stats then dex = math.floor(base_stats.stat_total["DEX"] * 0.5) end
	local total_def = self.ability:GetSpecialValueFor("def") + dex

	self.ability:AddBonus("_2_DEX", self.parent, -dex, 0, nil)
	self.ability:AddBonus("_2_DEF", self.parent, total_def, 0, nil)
end

-- EFFECTS -----------------------------------------------------------

function druid_2_modifier_armor:PlayEfxStart()
	local string = "particles/units/heroes/hero_treant/treant_livingarmor.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(particle, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_origin", self.parent:GetAbsOrigin(), true)
	self:AddParticle(particle, false, false, -1, false, false)
end