ancient_2_modifier_jump = class({})

--------------------------------------------------------------------------------

function ancient_2_modifier_jump:IsHidden()
	return true
end

function ancient_2_modifier_jump:IsPurgable()
	return true
end

--------------------------------------------------------------------------------

function ancient_2_modifier_jump:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
    self.ability = self:GetAbility()

    self.point = self.ability.point
	local duration = self.ability.duration
	local height = self.ability.height

	self.arc = self.parent:AddNewModifier(
		self.caster, -- player source
		self.ability, -- ability source
		"_modifier_generic_arc", -- modifier name
		{
			duration = duration,
			distance = 0,
			height = height,
			-- fix_end = true,
			fix_duration = false,
			isStun = true,
			--activity = ACT_DOTA_FLAIL,
		} -- kv
	)

	self.arc:SetEndCallback(function( interrupted )
		self:Destroy()	

        if IsServer() then
            self.parent:StopSound("Ancient.Jump")
            if interrupted then return end
            if self.duration >= 0.6 then self.parent:EmitSound("Ability.TossImpact") end
        end

        self.ability:CheckCombo()
	end)

	-- prepare horizontal motion
	local direction = self.point - self.parent:GetOrigin()
	local distance = direction:Length2D()
	direction.z = 0
	direction = direction:Normalized()

	-- init speed
	self.distance = distance
	if self.distance==0 then self.distance = 1 end
	self.duration = duration
	self.speed = distance/duration
	self.accel = 100
	self.max_speed = 3000

	-- apply motion
	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
	end

    if duration >= 0.4 then
        self:StartIntervalThink(duration - 0.4)
    end
end

function ancient_2_modifier_jump:OnRefresh( kv )
end

function ancient_2_modifier_jump:OnRemoved()
end

function ancient_2_modifier_jump:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController( self )
end

function ancient_2_modifier_jump:OnIntervalThink()
    self.parent:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
	self.parent:StartGesture(ACT_DOTA_CAST_ABILITY_5)
    if IsServer() then self.parent:EmitSound("Hero_ElderTitan.PreAttack") end

    self:StartIntervalThink(-1)
end

--------------------------------------------------------------------------------

function ancient_2_modifier_jump:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------

function ancient_2_modifier_jump:UpdateHorizontalMotion( me, dt )
	local target = self.point
	local parent = self.parent:GetOrigin()

	-- get current states
	local duration = self:GetElapsedTime()
	local direction = target-parent
	local distance = direction:Length2D()
	direction.z = 0
	direction = direction:Normalized()

	-- change speed if target farther/closer
	local original_distance = duration/self.duration * self.distance
	local expected_speed
	if self:GetElapsedTime()>=self.duration then
		expected_speed = self.speed
	else
		expected_speed = distance/(self.duration-self:GetElapsedTime())
	end

	-- accel/deccel speed
	if self.speed<expected_speed then
		self.speed = math.min(self.speed + self.accel, self.max_speed)
	elseif self.speed>expected_speed then
		self.speed = math.max(self.speed - self.accel, 0)
	end

	-- set relative position
	local pos = parent + direction * self.speed * dt
	me:SetOrigin( pos )
end

function ancient_2_modifier_jump:OnHorizontalMotionInterrupted()
	self:Destroy()
end

--------------------------------------------------------------------------------

function ancient_2_modifier_jump:GetEffectName()
	return "particles/units/heroes/hero_tiny/tiny_toss_blur.vpcf"
end

function ancient_2_modifier_jump:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end