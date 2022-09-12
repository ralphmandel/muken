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
	self.status_resist = 0
	self.armor = 0
	self.bonus_damage = 0

	self.interval = self.ability:GetSpecialValueFor("interval")
	self.heal = self.ability:GetSpecialValueFor("heal_per_sec") * self.interval
	local def = self.ability:GetSpecialValueFor("def")
	local armor = self.ability:GetSpecialValueFor("armor")

	-- UP 2.11
	if self.ability:GetRank(11) then
		def = def + 10
		armor = armor + 5
	end

	-- UP 2.21
	if self.ability:GetRank(21) then
		self.status_resist = 50
	end

	-- UP 2.22
	if self.ability:GetRank(22) then
		self:ChangeStats(15, "AGI", "_1_STR", "_1_AGI")
		if self.parent:IsHero() == false then
			self.bonus_damage = 20
		end
	end

	if self.parent:IsHero() == false then
		self.armor = armor
	end

	if IsServer() then
		self:ChangeStats(def, "DEX", "_2_DEF", "_2_DEX")
		self:StartIntervalThink(self.interval)
		self:PlayEfxStart()
	end
end

function druid_2_modifier_armor:OnRefresh(kv)
end

function druid_2_modifier_armor:OnRemoved()
	self.ability:RemoveBonus("_2_DEX", self.parent)
	self.ability:RemoveBonus("_2_DEF", self.parent)
	self.ability:RemoveBonus("_1_AGI", self.parent)
	self.ability:RemoveBonus("_1_STR", self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_2_modifier_armor:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_PHYSICAL_ARMOR_BONUS,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_PROPERTY_STATUS_RESISTANCE
	}

	return funcs
end

function druid_2_modifier_armor:GetModifierBaseAttack_BonusDamage()
	return self.armor
end

function druid_2_modifier_armor:GetModifierPhysicalArmorBonus()
	return self.bonus_damage
end

function druid_2_modifier_armor:OnAttackLanded(keys)
	if keys.target ~= self.parent then return end

	local bonus_per_atk = self.ability:GetSpecialValueFor("bonus_per_atk")
	self:SetDuration(self:GetRemainingTime() + bonus_per_atk, true)
end

function druid_2_modifier_armor:GetModifierStatusResistance()
	return self.status_resist
end

function druid_2_modifier_armor:OnIntervalThink()
	local heal = self.heal
	local base_stats = self.caster:FindAbilityByName("base_stats")
	if base_stats then heal = heal * base_stats:GetHealPower() end
	if heal >= 1 then self.parent:Heal(heal, self.ability) end

	-- UP 2.41
	if self.ability:GetRank(41) then
		self:FindAllies(heal)
	end

	if IsServer() then self:StartIntervalThink(self.interval) end
end

-- UTILS -----------------------------------------------------------

function druid_2_modifier_armor:ChangeStats(bonus, stat_convert, add, remove)
	local convert = 0
	local base_stats = self.parent:FindAbilityByName("base_stats")
	if base_stats then convert = math.floor(base_stats:GetStatTotal(stat_convert) * 0.5) end
	local total = convert + bonus

	self.ability:AddBonus(remove, self.parent, -convert, 0, nil)
	self.ability:AddBonus(add, self.parent, total, 0, nil)
end

function druid_2_modifier_armor:FindAllies(heal)
	local chance = 70

	local units = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, 800,
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false
	)

	for _,unit in pairs(units) do
		if RandomFloat(1, 100) <= chance
		and unit ~= self.parent then
			self.ability:CreateSeedProj(unit, self.parent, heal)
			chance = chance / 2.5
		end
	end
end

-- EFFECTS -----------------------------------------------------------

function druid_2_modifier_armor:PlayEfxStart()
	local string = "particles/units/heroes/hero_treant/treant_livingarmor.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControlEnt(particle, 1, self.parent, PATTACH_POINT_FOLLOW, "attach_origin", self.parent:GetAbsOrigin(), true)
	self:AddParticle(particle, false, false, -1, false, false)
end