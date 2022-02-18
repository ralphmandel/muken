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

	if IsServer() then self:StartIntervalThink(2) end
end

function bloodstained_1_modifier_berserk:OnRefresh( kv )
end

function bloodstained_1_modifier_berserk:OnRemoved()
	self.parent:SetForceAttackTarget(nil)
end

--------------------------------------------------------------------------------

function bloodstained_1_modifier_berserk:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true,
	}

	return state
end

function bloodstained_1_modifier_berserk:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK_FAIL
	}
	
	return funcs
end

function bloodstained_1_modifier_berserk:OnAttackLanded(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target ~= self.caster then return end

	if IsServer() then self:StartIntervalThink(2) end
end

function bloodstained_1_modifier_berserk:OnAttackFail(keys)
	if keys.attacker ~= self.parent then return end
	if keys.target ~= self.caster then return end

	if IsServer() then self:StartIntervalThink(2) end
end

function bloodstained_1_modifier_berserk:OnIntervalThink()
	self:Destroy()
end

--------------------------------------------------------------------------------

function bloodstained_1_modifier_berserk:GetStatusEffectName()
	return "particles/status_fx/status_effect_beserkers_call.vpcf"
end