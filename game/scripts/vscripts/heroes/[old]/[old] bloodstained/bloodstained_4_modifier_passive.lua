bloodstained_4_modifier_passive = class({})

function bloodstained_4_modifier_passive:IsHidden() return true end
function bloodstained_4_modifier_passive:IsPurgable() return false end

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

	self:PerformFrenzy(keys.target)
	self:ApplyBleed(keys.target)
end

-- UTILS -----------------------------------------------------------

function bloodstained_4_modifier_passive:PerformFrenzy(target)
	if self.parent:HasModifier("bloodstained_4_modifier_frenzy") then return end
	if self.ability:IsCooldownReady() == false then return end

	if RandomFloat(0, 100) < self.ability:GetSpecialValueFor("chance") then
		self.ability.target = target
		self.parent:AddNewModifier(self.caster, self.ability, "bloodstained_4_modifier_frenzy", {
			duration = CalcStatus(self.ability:GetSpecialValueFor("duration"), self.caster, self.parent)
		})
	end
end

function bloodstained_4_modifier_passive:ApplyBleed(target)
	if RandomFloat(0, 100) < self.ability:GetSpecialValueFor("special_bleed_chance") then
		target:RemoveModifierByNameAndCaster("bloodstained__modifier_bleeding", self.caster)
		target:AddNewModifier(self.caster, self.ability, "bloodstained__modifier_bleeding", {
			duration = CalcStatus(self.ability:GetSpecialValueFor("special_bleed_duration"), self.caster, target)
		})
	end
end

-- EFFECTS -----------------------------------------------------------