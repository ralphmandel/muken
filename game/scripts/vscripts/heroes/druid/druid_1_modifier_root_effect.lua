druid_1_modifier_root_effect = class({})

function druid_1_modifier_root_effect:IsHidden()
	return true
end

function druid_1_modifier_root_effect:IsPurgable()
	return false
end

function druid_1_modifier_root_effect:IsDebuff()
	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_1_modifier_root_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.interval = 0.3
	local root_interval = self.ability:GetSpecialValueFor("root_duration")
	local root_duration = self.ability:GetSpecialValueFor("root_duration")

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_root", {
		duration = self.ability:CalcStatus(root_duration, self.caster, self.parent),
		effect = 5
	})
	
	if IsServer() then
		self:SetDuration(root_interval, true)
		self:StartIntervalThink(self.interval)
	end
end

function druid_1_modifier_root_effect:OnRefresh(kv)
end

function druid_1_modifier_root_effect:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_1_modifier_root_effect:OnIntervalThink()
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