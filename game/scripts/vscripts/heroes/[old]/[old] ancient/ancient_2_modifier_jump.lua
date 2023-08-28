ancient_2_modifier_jump = class({})

function ancient_2_modifier_jump:IsHidden() return true end
function ancient_2_modifier_jump:IsPurgable() return false end
function ancient_2_modifier_jump:GetPriority() return MODIFIER_PRIORITY_SUPER_ULTRA end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_2_modifier_jump:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
  self.ability = self:GetAbility()

  self.arc = AddModifier(self.parent, self.ability, "_modifier_generic_arc", {
    duration = self.ability.duration, distance = 0, height = self.ability.height, --fix_end = true,
    fix_duration = false, isStun = true, --activity = ACT_DOTA_FLAIL
  }, false)

	self.arc:SetEndCallback(function(interrupted)
		self:Destroy()	

    if IsServer() then
      self.parent:StopSound("Ancient.Jump")
      if interrupted then
        --self.parent:FindModifierByName(self.ability:GetIntrinsicModifierName()):SetStackCount(0)
        return
      end
      if self.ability.duration >= 0.6 then self.parent:EmitSound("Ability.TossImpact") end
    end

    AddModifier(self.parent, self.ability, "ancient_2_modifier_leap", {}, false)
	end)

	if self.ability.distance == 0 then self.ability.distance = 1 end
	self.speed = self.ability.distance / self.ability.duration
	self.accel = 100
	self.max_speed = 3000

	-- apply motion
	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
	end

  if self.ability.duration >= 0.4 then
    self:StartIntervalThink(self.ability.duration - 0.4)
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

-- API FUNCTIONS -----------------------------------------------------------

function ancient_2_modifier_jump:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

function ancient_2_modifier_jump:OnIntervalThink()
  self.parent:FadeGesture(ACT_DOTA_CAST_ABILITY_1)
	self.parent:StartGestureWithPlaybackRate(ACT_DOTA_CAST_ABILITY_5, 1)
  if IsServer() then self.parent:EmitSound("Hero_ElderTitan.PreAttack") end

  self:StartIntervalThink(-1)
end

-- MOTIONS -----------------------------------------------------------

function ancient_2_modifier_jump:UpdateHorizontalMotion( me, dt )
	-- get current states
	local duration = self:GetElapsedTime()
	local direction = self.ability.point - self.parent:GetOrigin()
	local distance = direction:Length2D()
	direction.z = 0
	direction = direction:Normalized()

	-- change speed if target farther/closer
	local expected_speed
	if self:GetElapsedTime() >= self.ability.duration then
		expected_speed = self.speed
	else
		expected_speed = distance / (self.ability.duration - self:GetElapsedTime())
	end

	-- accel/deccel speed
	if self.speed<expected_speed then
		self.speed = math.min(self.speed + self.accel, self.max_speed)
	elseif self.speed>expected_speed then
		self.speed = math.max(self.speed - self.accel, 0)
	end

	-- set relative position
	local pos = self.parent:GetOrigin() + direction * self.speed * dt
	me:SetOrigin( pos )
end

function ancient_2_modifier_jump:OnHorizontalMotionInterrupted()
	self:Destroy()
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function ancient_2_modifier_jump:GetEffectName()
	return "particles/units/heroes/hero_tiny/tiny_toss_blur.vpcf"
end

function ancient_2_modifier_jump:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end