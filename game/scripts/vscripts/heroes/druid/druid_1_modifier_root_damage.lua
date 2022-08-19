druid_1_modifier_root_damage = class({})

function druid_1_modifier_root_damage:IsHidden()
	return true
end

function druid_1_modifier_root_damage:IsPurgable()
	return false
end

function druid_1_modifier_root_damage:IsDebuff()
	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_1_modifier_root_damage:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	self.interval = 0.3
	
	if IsServer() then self:StartIntervalThink(self.interval) end
end

function druid_1_modifier_root_damage:OnRefresh(kv)
end

function druid_1_modifier_root_damage:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_1_modifier_root_damage:OnIntervalThink()
	ApplyDamage({
		victim = self.parent, attacker = self.caster,
		damage = self.ability:GetAbilityDamage() * self.interval,
		damage_type = self.ability:GetAbilityDamageType(),
        ability = self.ability
	})

	if IsServer() then self:StartIntervalThink(self.interval) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------