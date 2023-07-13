bloodstained_2_modifier_passive = class({})

function bloodstained_2_modifier_passive:IsHidden() return true end
function bloodstained_2_modifier_passive:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_2_modifier_passive:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()
end

function bloodstained_2_modifier_passive:OnRefresh(kv)
end

function bloodstained_2_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function bloodstained_2_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}

	return funcs
end

function bloodstained_2_modifier_passive:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if self.parent:PassivesDisabled() then return end
	if self.parent:HasModifier("bloodstained_2_modifier_frenzy") then return end
	if self.ability:IsCooldownReady() == false then return end

	if RandomFloat(0, 100) < self.ability:GetSpecialValueFor("chance") then
    self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
		self.ability.target = keys.target
    AddModifier(self.parent, self.caster, self.ability, "bloodstained_2_modifier_frenzy", {
      duration = self.ability:GetSpecialValueFor("duration")
    }, true)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------