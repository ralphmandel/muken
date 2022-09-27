icebreaker_5_modifier_illusion = class({})

function icebreaker_5_modifier_illusion:IsHidden()
	return true
end

function icebreaker_5_modifier_illusion:IsPurgable()
    return false
end

function icebreaker_5_modifier_illusion:IsDebuff()
	return false
end

--------------------------------------------------------------------------------

function icebreaker_5_modifier_illusion:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.stop = false
	self.min_health = 1

	if IsServer() then self:StartIntervalThink(FrameTime()) end
end

function icebreaker_5_modifier_illusion:OnRefresh( kv )
end

function icebreaker_5_modifier_illusion:OnDestroy( kv )
end

--------------------------------------------------------------------------------

function icebreaker_5_modifier_illusion:GetPriority()
	return MODIFIER_PRIORITY_HIGH
end

function icebreaker_5_modifier_illusion:CheckState()
	local state = {
        [MODIFIER_STATE_IGNORING_MOVE_AND_ATTACK_ORDERS] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true
	}

	return state
end

function icebreaker_5_modifier_illusion:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MIN_HEALTH,
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_FIXED_ATTACK_RATE,
		MODIFIER_PROPERTY_BASE_ATTACK_TIME_CONSTANT,
		MODIFIER_EVENT_ON_ATTACK_LANDED
	}
	
	return funcs
end

function icebreaker_5_modifier_illusion:GetMinHealth()
	return self.min_health
end

function icebreaker_5_modifier_illusion:GetModifierMoveSpeedBonus_Percentage()
	return 50
end


function icebreaker_5_modifier_illusion:GetModifierFixedAttackRate()
	return 1.2
end

function icebreaker_5_modifier_illusion:GetModifierBaseAttackTimeConstant()
    return 1.2
end

function icebreaker_5_modifier_illusion:OnAttackLanded(keys)
	if keys.target == self.parent then
		self.min_health = 0
		self.parent:ForceKill(false)
		return
	end
end

function icebreaker_5_modifier_illusion:OnIntervalThink()
	local found = false
	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, 1000, DOTA_UNIT_TARGET_TEAM_ENEMY,
		DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	128, 1, false
	)

	for _,enemy in pairs(enemies) do
		if enemy:HasModifier("icebreaker_1_modifier_frozen") == false
		and found == false then
			self.parent:Interrupt()
			self.parent:SetForceAttackTarget(enemy)
			self.parent:MoveToTargetToAttack(enemy)
			self.stop = false
			found = true
		end
	end

	if found == false and self.stop == false then
		self.parent:SetForceAttackTarget(nil)
		self.parent:Stop()
		self.parent:Hold()
		self.stop = true
	end

	if IsServer() then self:StartIntervalThink(FrameTime()) end
end