bloodstained_1_modifier_call = class({})

function bloodstained_1_modifier_call:IsHidden() return false end
function bloodstained_1_modifier_call:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function bloodstained_1_modifier_call:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.parent:SetForceAttackTarget(self.caster)
	self.parent:MoveToTargetToAttack(self.caster)

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "bloodstained_1_modifier_call_status_efx", true) end
end

function bloodstained_1_modifier_call:OnRefresh(kv)
end

function bloodstained_1_modifier_call:OnRemoved()
	self.parent:SetForceAttackTarget(nil)

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "bloodstained_1_modifier_call_status_efx", false) end
end

-- API FUNCTIONS -----------------------------------------------------------

function bloodstained_1_modifier_call:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true
	}

	return state
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bloodstained_1_modifier_call:GetStatusEffectName()
	return "particles/status_fx/status_effect_beserkers_call.vpcf"
end

function bloodstained_1_modifier_call:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end