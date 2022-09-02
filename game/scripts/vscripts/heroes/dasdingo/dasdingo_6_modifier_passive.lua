dasdingo_6_modifier_passive = class({})

function dasdingo_6_modifier_passive:IsHidden()
	return false
end

function dasdingo_6_modifier_passive:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function dasdingo_6_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function dasdingo_6_modifier_passive:OnRefresh(kv)
end

function dasdingo_6_modifier_passive:OnRemoved()
end

--------------------------------------------------------------------------------

function dasdingo_6_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_FAIL,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function dasdingo_6_modifier_passive:OnAttackFail(keys)
	if keys.attacker ~= self.parent then return end
	if self.parent:PassivesDisabled() then return end

	-- UP 6.22
	if self.ability:GetRank(22) then
		local fire_duration = self.ability:GetSpecialValueFor("fire_duration") + 5

		keys.target:AddNewModifier(self.caster, self.ability, "dasdingo_6_modifier_fire", {
			duration = self.ability:CalcStatus(fire_duration, self.caster, keys.target)
		})
	end
end

function dasdingo_6_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if self.parent:PassivesDisabled() then return end

	local fire_duration = self.ability:GetSpecialValueFor("fire_duration")

	-- UP 6.22
	if self.ability:GetRank(22) then
		fire_duration = fire_duration + 5
	end

	keys.target:AddNewModifier(self.caster, self.ability, "dasdingo_6_modifier_fire", {
		duration = self.ability:CalcStatus(fire_duration, self.caster, keys.target)
	})
end