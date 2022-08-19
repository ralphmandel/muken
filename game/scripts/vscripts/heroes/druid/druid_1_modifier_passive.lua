druid_1_modifier_passive = class({})

function druid_1_modifier_passive:IsHidden()
	return true
end

function druid_1_modifier_passive:IsPurgable()
	return false
end

function druid_1_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_1_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.location = self.parent:GetOrigin()
end

function druid_1_modifier_passive:OnRefresh(kv)
end

function druid_1_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_UNIT_MOVED,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function druid_1_modifier_passive:OnUnitMoved(keys)
	if keys.unit ~= self.parent then return end
	if self.parent:PassivesDisabled() then return end

	-- UP 1.41
	if self.ability:GetRank(41) then
		self:CreateBushPath()
	end
end

function druid_1_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self.parent:PassivesDisabled() then return end

	-- UP 1.31
	if self.ability:GetRank(31) then
		self:ApplyBushAttack(keys.target)
	end
end

-- UTILS -----------------------------------------------------------

function druid_1_modifier_passive:CreateBushPath()
	local origin = self.parent:GetOrigin()
	local distance = (origin - self.location):Length2D()
	local radius = self.ability:GetSpecialValueFor("radius") * 0.75
	local bush_duration = RandomFloat(3, 5)

	if distance >= radius / 3 then
		self.ability:CreateBush(self.ability:RandomizeLocation(self.location, origin, radius), bush_duration, 2)
		self.location = origin
	end
end

function druid_1_modifier_passive:ApplyBushAttack(target)
	local chance = 20
	local bush_duration = RandomFloat(5, 10)
	local point = target:GetAbsOrigin() + RandomVector(RandomInt(1, 50))

	local base_stats = self.parent:FindAbilityByName("base_stats")
	if base_stats then chance = chance * base_stats:GetCriticalChance() end

	if RandomFloat(1, 100) <= chance then
		self.ability:CreateBush(point, bush_duration, 1)
	end
end
-- EFFECTS -----------------------------------------------------------