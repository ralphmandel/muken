bocuse_2_modifier_casting = class ({})

function bocuse_2_modifier_casting:IsHidden()
    return true
end

function bocuse_2_modifier_casting:IsPurgable()
    return false
end

function bocuse_2_modifier_casting:GetPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

-----------------------------------------------------------

function bocuse_2_modifier_casting:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

    self.parent:StartGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
	self:StartIntervalThink(0.4)
end

function bocuse_2_modifier_casting:OnRefresh(kv)
end

function bocuse_2_modifier_casting:OnRemoved()
    self.parent:RemoveGesture(ACT_DOTA_OVERRIDE_ABILITY_1)
end

------------------------------------------------------------

function bocuse_2_modifier_casting:CheckState()
	local state = {
		[MODIFIER_STATE_COMMAND_RESTRICTED] = true
	}

	return state
end

function bocuse_2_modifier_casting:OnIntervalThink()
	self.parent:StartGesture(1520)
	self:StartIntervalThink(-1)
end