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

	local root_interval = self.ability:GetSpecialValueFor("root_interval")
	local root_duration = self.ability:GetSpecialValueFor("root_duration")

	self.parent:AddNewModifier(self.caster, self.ability, "druid_1_modifier_root_damage", {})

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_root", {
		duration = self.ability:CalcStatus(root_duration, self.caster, self.parent),
		effect = 5
	})
	
	if IsServer() then self:StartIntervalThink(root_interval) end
end

function druid_1_modifier_root_effect:OnRefresh(kv)
end

function druid_1_modifier_root_effect:OnRemoved()
	local mod = self.parent:FindAllModifiersByName("druid_1_modifier_root_damage")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_1_modifier_root_effect:OnIntervalThink()
	self:Destroy()
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------