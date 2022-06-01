shadow_2_modifier_vacuum = class({})

function shadow_2_modifier_vacuum:IsHidden()
	return true
end

function shadow_2_modifier_vacuum:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function shadow_2_modifier_vacuum:OnCreated( kv )
	if not IsServer() then return end

	-- set direction and speed
	local center = Vector( kv.x, kv.y, 0 )
	self.direction = center - self:GetParent():GetOrigin()
	self.speed = self.direction:Length2D()/self:GetDuration()

	self.direction.z = 0
	self.direction = self.direction:Normalized()

	--apply motion
	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
	end
end

function shadow_2_modifier_vacuum:OnRefresh( kv )
	self:OnCreated( kv )
end

function shadow_2_modifier_vacuum:OnRemoved()
end

function shadow_2_modifier_vacuum:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController( self )
end

--------------------------------------------------------------------------------

function shadow_2_modifier_vacuum:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function shadow_2_modifier_vacuum:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

--------------------------------------------------------------------------------

function shadow_2_modifier_vacuum:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true,
	}

	return state
end

--------------------------------------------------------------------------------

function shadow_2_modifier_vacuum:UpdateHorizontalMotion( me, dt )
	local target = me:GetOrigin() + self.direction * self.speed * dt
	me:SetOrigin( target )
end

function shadow_2_modifier_vacuum:OnHorizontalMotionInterrupted()
	self:Destroy()
end