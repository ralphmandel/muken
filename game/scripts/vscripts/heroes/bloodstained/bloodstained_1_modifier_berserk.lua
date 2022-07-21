bloodstained_1_modifier_berserk = class({})

--------------------------------------------------------------------------------

function bloodstained_1_modifier_berserk:IsHidden()
	return false
end

function bloodstained_1_modifier_berserk:IsPurgable()
	return true
end

--------------------------------------------------------------------------------

function bloodstained_1_modifier_berserk:OnCreated( kv )
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.origin = self.caster:GetOrigin()

	if IsServer() then self:StartIntervalThink(0.2) end

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, nil, "bloodstained_1_modifier_berserk_status_efx", true) end
end

function bloodstained_1_modifier_berserk:OnRefresh( kv )
end

function bloodstained_1_modifier_berserk:OnRemoved()
	self.parent:SetForceAttackTarget(nil)

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, nil, "bloodstained_1_modifier_berserk_status_efx", false) end
end

--------------------------------------------------------------------------------

function bloodstained_1_modifier_berserk:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}

	return state
end

function bloodstained_1_modifier_berserk:OnIntervalThink()
	if self.origin == nil then self:Destroy() return end

	local distance = (self.origin - self.caster:GetOrigin()):Length2D()
	if distance > self.ability:GetCastRange(self.caster:GetOrigin(), nil) then self:Destroy() end
end

--------------------------------------------------------------------------------

function bloodstained_1_modifier_berserk:GetStatusEffectName()
	return "particles/status_fx/status_effect_beserkers_call.vpcf"
end

function bloodstained_1_modifier_berserk:StatusEffectPriority()
	return MODIFIER_PRIORITY_NORMAL
end