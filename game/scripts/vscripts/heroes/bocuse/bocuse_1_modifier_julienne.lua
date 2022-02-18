bocuse_1_modifier_julienne = class ({})

function bocuse_1_modifier_julienne:IsHidden()
    return true
end

function bocuse_1_modifier_julienne:IsPurgable()
    return false
end

-----------------------------------------------------------

function bocuse_1_modifier_julienne:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local flambee = self.parent:FindAbilityByName("bocuse_2__flambee")
	if flambee then
		if flambee:IsTrained() then flambee:SetActivated(false) end
	end

	local mise = self.parent:FindAbilityByName("bocuse_u__mise")
	if mise then
		if mise:IsTrained() then mise:SetActivated(false) end
	end

	self.ability:SetActivated(false)
    self:StartIntervalThink(FrameTime())
end

function bocuse_1_modifier_julienne:OnRefresh(kv)
end

function bocuse_1_modifier_julienne:OnRemoved()
    self.parent:FadeGesture(ACT_DOTA_ATTACK)

	if self.ability.target ~= nil then
		if IsValidEntity(self.ability.target) then
			if self.ability.target:IsAlive() then
				self.parent:MoveToTargetToAttack(self.ability.target)
			end
		end
	end

	local flambee = self.parent:FindAbilityByName("bocuse_2__flambee")
	if flambee then
		if flambee:IsTrained() then flambee:SetActivated(true) end
	end

	local mise = self.parent:FindAbilityByName("bocuse_u__mise")
	if mise then
		if mise:IsTrained() then mise:SetActivated(true) end
	end

	local charges = self.parent:FindModifierByName("bocuse_1_modifier_charges")
	if charges then
		charges:CheckCharges()
	end
end

------------------------------------------------------------

function bocuse_1_modifier_julienne:CheckState()
	local state = {
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end

function bocuse_1_modifier_julienne:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_DISABLE_TURNING
	}

	return funcs
end

function bocuse_1_modifier_julienne:GetModifierMoveSpeedBonus_Percentage()
	return -50
end

function bocuse_1_modifier_julienne:GetModifierDisableTurning()
	return 1
end

function bocuse_1_modifier_julienne:OnIntervalThink()
	if self.ability.target ~= nil then
		if IsValidEntity(self.ability.target) then
			self.parent:SetForwardVector((self.ability.target:GetAbsOrigin() - self.parent:GetAbsOrigin()):Normalized())
		end
	end
end