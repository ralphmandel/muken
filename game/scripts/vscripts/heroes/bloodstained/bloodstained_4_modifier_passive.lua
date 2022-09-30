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
	if self.parent:PassivesDisabled() then return end
	if self.parent:HasModifier("bloodstained_4_modifier_frenzy") then return end

	local chance = self.ability:GetSpecialValueFor("chance")
	local duration = self.ability:GetSpecialValueFor("duration")

	if RandomInt(1, 100) <= chance then
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