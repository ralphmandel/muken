bald_5_modifier_call = class({})

function bald_5_modifier_call:IsHidden() return false end
function bald_5_modifier_call:IsPurgable() return true end

-- CONSTRUCTORS -----------------------------------------------------------

function bald_5_modifier_call:OnCreated(kv)
  self.caster = self:GetCaster()
  self.parent = self:GetParent()
  self.ability = self:GetAbility()

	self.parent:SetForceAttackTarget(self.caster)
	self.parent:MoveToTargetToAttack(self.caster)

  AddStatusEfx(self.ability, "bald_5_modifier_call_status_efx", self.caster, self.parent)
end

function bald_5_modifier_call:OnRefresh(kv)
end

function bald_5_modifier_call:OnRemoved()
	self.parent:SetForceAttackTarget(nil)

  RemoveStatusEfx(self.ability, "bald_5_modifier_call_status_efx", self.caster, self.parent)
end

-- API FUNCTIONS -----------------------------------------------------------

function bald_5_modifier_call:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true
	}

	return state
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bald_5_modifier_call:GetStatusEffectName()
	return "particles/status_fx/status_effect_beserkers_call.vpcf"
end

function bald_5_modifier_call:StatusEffectPriority()
	return MODIFIER_PRIORITY_HIGH
end