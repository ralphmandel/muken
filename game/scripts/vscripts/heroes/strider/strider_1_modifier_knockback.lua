strider_1_modifier_knockback = class ({})

function strider_1_modifier_knockback:IsHidden()
    return false
end

function strider_1_modifier_knockback:IsPurgable()
    return false
end

-----------------------------------------------------------

function strider_1_modifier_knockback:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	-- set direction and speed
	local center = Vector( kv.x, kv.y, 0 )
	self.direction = center - self.parent:GetOrigin()
	self.speed = self.direction:Length2D()/self:GetDuration()

	self.direction.z = 0
	self.direction = self.direction:Normalized()

	--apply motion
	if not self:ApplyHorizontalMotionController() then
		self:Destroy()
        return
	end

	self:PlayEfxStart()
end

function strider_1_modifier_knockback:OnRefresh(kv)
    self:OnCreated(kv)
end

function strider_1_modifier_knockback:OnRemoved()
end

function strider_1_modifier_knockback:OnDestroy()
	if not IsServer() then return end
	self.parent:RemoveHorizontalMotionController( self )
end

--------------------------------------------------------------------------------

function strider_1_modifier_knockback:CheckState()
	local state = {
        [MODIFIER_STATE_STUNNED] = true
	}

	return state
end

function strider_1_modifier_knockback:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
	}

	return funcs
end

function strider_1_modifier_knockback:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

--------------------------------------------------------------------------------

function strider_1_modifier_knockback:UpdateHorizontalMotion( me, dt )
	local target = me:GetOrigin() + self.direction * self.speed * dt
	me:SetOrigin( target )
end

function strider_1_modifier_knockback:OnHorizontalMotionInterrupted()
	self:Destroy()
end

--------------------------------------------------------------------------------

function strider_1_modifier_knockback:PlayEfxStart()
	if IsServer() then self.parent:EmitSound("Hero_FacelessVoid.TimeWalk") end
end