bocuse_u_modifier_passive = class({})

function bocuse_u_modifier_passive:IsHidden()
	return false
end

function bocuse_u_modifier_passive:IsPurgable()
	return false
end

function bocuse_u_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_u_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:SetStackCount(0) end
end

function bocuse_u_modifier_passive:OnRefresh(kv)
end

function bocuse_u_modifier_passive:OnRemoved(kv)
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_u_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_HERO_KILLED,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	
	return funcs
end

function bocuse_u_modifier_passive:OnHeroKilled(keys)
	if keys.attacker == nil or keys.target == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self.parent:HasModifier("bocuse_u_modifier_rage") == false then return end

	self.ability:AddKillPoint(1)
	self:SetStackCount(self.ability.kills)
end

function bocuse_u_modifier_passive:OnAttackLanded(keys)
    if not (keys.attacker == self.parent) then return end
    if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
    if self.parent:PassivesDisabled() then return end
	if self.parent:HasModifier("bocuse_u_modifier_rage") then return end

    -- UP 6.32
    if self.ability:GetRank(32) and RandomFloat(1, 100) <= 10 then
        self.parent:AddNewModifier(self.caster, self.ability, "bocuse_u_modifier_rage", {
            duration = self.ability:CalcStatus(1, self.caster, self.parent),
            autocasted = 1
        })
    end
end