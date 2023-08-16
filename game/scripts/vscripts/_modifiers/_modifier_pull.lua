_modifier_pull = class({})

function _modifier_pull:IsHidden() return true end
function _modifier_pull:IsPurgable() return false end

--------------------------------------------------------------------------------

function _modifier_pull:OnCreated( kv )
	if not IsServer() then return end

	local center = Vector( kv.x, kv.y, 0 )
	self.direction = center - self:GetParent():GetOrigin()
	self.speed = self.direction:Length2D()/self:GetDuration()

	self.direction.z = 0
	self.direction = self.direction:Normalized()

	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
	end
end

function _modifier_pull:OnRefresh( kv )
	self:OnCreated( kv )
end

function _modifier_pull:OnRemoved()
end

function _modifier_pull:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController( self )
end

--------------------------------------------------------------------------------

function _modifier_pull:UpdateHorizontalMotion( me, dt )
	local target = me:GetOrigin() + self.direction * self.speed * dt
	me:SetOrigin( target )
end

function _modifier_pull:OnHorizontalMotionInterrupted()
	self:Destroy()
end

--------------------------------------------------------------------------------

function _modifier_pull:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_DISABLE_TURNING,
    MODIFIER_PROPERTY_OVERRIDE_ANIMATION
	}

	return funcs
end

function _modifier_pull:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end