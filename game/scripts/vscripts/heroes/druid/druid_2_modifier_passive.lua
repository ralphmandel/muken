druid_2_modifier_passive = class({})

function druid_2_modifier_passive:IsHidden()
	return true
end

function druid_2_modifier_passive:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function druid_2_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function druid_2_modifier_passive:OnRefresh(kv)
end

function druid_2_modifier_passive:OnRemoved()
end

--------------------------------------------------------------------------------

function druid_2_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function druid_2_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target:GetTeamNumber() == self.parent:GetTeamNumber() then return end
	if self.parent:PassivesDisabled() then return end

	local root_duration = self.ability:GetSpecialValueFor("root_duration")

	-- UP 2.31
	if self.ability:GetRank(31)
	and RandomInt(1, 100) <= 15
	and keys.target:IsAlive() then
		keys.target:AddNewModifier(self.caster, self.ability, "_modifier_root", {
			duration = self.ability:CalcStatus(root_duration, self.caster, self.parent),
			effect = 5
		})
	end
end