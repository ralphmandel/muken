genuine_3_modifier_passive = class({})

function genuine_3_modifier_passive:IsHidden()
	return false
end

function genuine_3_modifier_passive:IsPurgable()
	return false
end

-----------------------------------------------------------

function genuine_3_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:SetStackCount(0) end
end

function genuine_3_modifier_passive:OnRefresh(kv)
end

function genuine_3_modifier_passive:OnRemoved(kv)
end

-----------------------------------------------------------

function genuine_3_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_HERO_KILLED
	}
	
	return funcs
end

function genuine_3_modifier_passive:OnHeroKilled(keys)
	if keys.attacker == nil or keys.target == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end

	self.ability:AddKillPoint(1)
	self:SetStackCount(self.ability.kills)
end