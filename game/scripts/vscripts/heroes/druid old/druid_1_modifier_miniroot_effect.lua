druid_1_modifier_miniroot_effect = class({})

function druid_1_modifier_miniroot_effect:IsHidden()
	return true
end

function druid_1_modifier_miniroot_effect:IsPurgable()
	return false
end

function druid_1_modifier_miniroot_effect:IsDebuff()
	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_1_modifier_miniroot_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
	
	if IsServer() then
		self:ApplyRoot()
		self:StartIntervalThink(1)
	end
end

function druid_1_modifier_miniroot_effect:OnRefresh(kv)
end

function druid_1_modifier_miniroot_effect:OnRemoved()
	if self.parent:HasModifier("druid_1_modifier_root_effect") then return end
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_1_modifier_miniroot_effect:OnIntervalThink()
	if IsServer() then
		self:ApplyRoot()
		self:StartIntervalThink(1)
	end
end

-- UTILS -----------------------------------------------------------

function druid_1_modifier_miniroot_effect:ApplyRoot()
	if RandomFloat(1, 100) < 25 then
		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_root", {
			duration = CalcStatus(0.75, self.caster, self.parent),
			effect = 5
		})
	end
end

-- EFFECTS -----------------------------------------------------------