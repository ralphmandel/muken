bloodstained_4_modifier_passive = class({})

function bloodstained_4_modifier_passive:IsHidden()
	return true
end

function bloodstained_4_modifier_passive:IsPurgable()
	return false
end

function bloodstained_4_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_4_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()
end

function bloodstained_4_modifier_passive:OnRefresh(kv)
end

function bloodstained_4_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function bloodstained_4_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function bloodstained_4_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if self.parent:GetTeamNumber() == keys.target:GetTeamNumber() then return end
	if self.parent:PassivesDisabled() then return end
	if self.parent:HasModifier("bloodstained_4_modifier_frenzy") then return end
	if self.ability:IsCooldownReady() == false then return end

	local chance = self.ability:GetSpecialValueFor("chance")
	local duration = self.ability:GetSpecialValueFor("duration")

	-- UP 4.21
	if self.ability:GetRank(21) then
		chance = chance + 2
	end

	-- UP 4.31
	if self.ability:GetRank(31) then
		duration = duration + 1
	end

	if RandomFloat(1, 100) <= chance then
		-- UP 4.21
		if self.ability:GetRank(21) then
			self.parent:Purge(false, true, false, false, false)
		end

		self.ability.target = keys.target
		self.parent:AddNewModifier(self.caster, self.ability, "bloodstained_4_modifier_frenzy", {
			duration = self.ability:CalcStatus(duration, self.caster, self.parent)
		})
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bloodstained_4_modifier_passive:GetEffectName()
	return ""
end

function bloodstained_4_modifier_passive:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end