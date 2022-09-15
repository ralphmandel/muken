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
	self:ApplyDebuff()

	local root_interval = self.ability:GetSpecialValueFor("root_interval")
	
	if IsServer() then self:StartIntervalThink(root_interval) end
end

function druid_1_modifier_root_effect:OnRefresh(kv)
end

function druid_1_modifier_root_effect:OnRemoved()
	if self.parent:HasModifier("druid_1_modifier_miniroot_effect") then return end
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_1_modifier_root_effect:CheckState()
	local state = {}

	if self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber() then
		state = {[MODIFIER_STATE_ALLOW_PATHING_THROUGH_CLIFFS] = true}
	end

	return state
end

function druid_1_modifier_root_effect:OnIntervalThink()
	self:Destroy()
end

-- UTILS -----------------------------------------------------------

function druid_1_modifier_root_effect:ApplyDebuff()
	if self.caster:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	local root_duration = self.ability:CalcStatus(self.ability:GetSpecialValueFor("root_duration"), self.caster, self.parent)

	self.parent:AddNewModifier(self.caster, self.ability, "_modifier_root", {duration = root_duration, effect = 5})
end

-- EFFECTS -----------------------------------------------------------