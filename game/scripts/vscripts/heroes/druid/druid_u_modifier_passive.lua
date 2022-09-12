druid_u_modifier_passive = class({})

function druid_u_modifier_passive:IsHidden()
	return false
end

function druid_u_modifier_passive:IsPurgable()
	return false
end

function druid_u_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_u_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:SetStackCount(0) end
end

function druid_u_modifier_passive:OnRefresh(kv)
end

function druid_u_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------