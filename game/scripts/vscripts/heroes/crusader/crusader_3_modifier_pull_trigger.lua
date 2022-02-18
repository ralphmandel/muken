crusader_3_modifier_pull_trigger = class({})

--------------------------------------------------------------------------------
-- Classifications
function crusader_3_modifier_pull_trigger:IsHidden()
	return true
end

function crusader_3_modifier_pull_trigger:IsPurgable()
	return false
end

--------------------------------------------------------------------------------
-- Initializations
function crusader_3_modifier_pull_trigger:OnCreated( kv )
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

function crusader_3_modifier_pull_trigger:OnRefresh( kv )
	self:OnCreated( kv )
end

function crusader_3_modifier_pull_trigger:OnRemoved()
end

function crusader_3_modifier_pull_trigger:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController( self )
end

--------------------------------------------------------------------------------
-- Modifier Effects
-- function crusader_3_modifier_pull_trigger:DeclareFunctions()
-- 	local funcs = {
-- 		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
-- 	}

-- 	return funcs
-- end

-- function crusader_3_modifier_pull_trigger:GetOverrideAnimation()
-- 	return ACT_DOTA_FLAIL
-- end

--------------------------------------------------------------------------------
-- Status Effects
-- function crusader_3_modifier_pull_trigger:CheckState()
-- 	local state = {
-- 		[MODIFIER_STATE_STUNNED] = true,
-- 	}

-- 	return state
-- end

--------------------------------------------------------------------------------
-- Motion Effects
function crusader_3_modifier_pull_trigger:UpdateHorizontalMotion( me, dt )
	local target = me:GetOrigin() + self.direction * self.speed * dt
	me:SetOrigin( target )
end

function crusader_3_modifier_pull_trigger:OnHorizontalMotionInterrupted()
	self:Destroy()
end