bocuse_u_modifier_jump = class ({})

function bocuse_u_modifier_jump:IsHidden()
    return true
end

function bocuse_u_modifier_jump:IsPurgable()
    return false
end

-----------------------------------------------------------

function bocuse_u_modifier_jump:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	--self.parent:StartGestureWithPlaybackRate(ACT_DOTA_FORCESTAFF_END, 0.75)
	self:StartIntervalThink(FrameTime())
	self.angle = self.parent:GetForwardVector():Normalized()
	self.distance = 400 / ( self:GetDuration() / FrameTime())
end

function bocuse_u_modifier_jump:OnRefresh(kv)
end

function bocuse_u_modifier_jump:OnRemoved()
    -- local duration = self.ability:GetSpecialValueFor("duration")
    -- self.parent:AddNewModifier(self.caster, self.ability, "bocuse_u_modifier_mise", {duration = duration})
end

function bocuse_u_modifier_jump:OnDestroy()
	if not IsServer() then return end
	--self.parent:FadeGesture(ACT_DOTA_FORCESTAFF_END)
	ResolveNPCPositions(self.parent:GetAbsOrigin(), 128)
end

------------------------------------------------------------

function bocuse_u_modifier_jump:OnIntervalThink()
	self:HorizontalMotion(self.parent, FrameTime())
end

function bocuse_u_modifier_jump:HorizontalMotion(unit, time)
	if not IsServer() then return end

    local units = FindUnitsInRadius(
        self.caster:GetTeamNumber(),	-- int, your team number
        self.parent:GetOrigin(),	-- point, center point
        nil,	-- handle, cacheUnit. (not known)
        50,	-- float, radius. or use FIND_UNITS_EVERYWHERE
        DOTA_UNIT_TARGET_TEAM_ENEMY,	-- int, team filter
        DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,	-- int, type filter
        0,	-- int, flag filter
        0,	-- int, order filter
        false	-- bool, can grow cache
    )

	local pos = unit:GetAbsOrigin()
	GridNav:DestroyTreesAroundPoint(pos, 80, false)
	local pos_p = self.angle * self.distance
	local next_pos = GetGroundPosition(pos + pos_p,unit)
	unit:SetAbsOrigin(next_pos)

    for _,unit in pairs(units) do
        self:Destroy()
    end
end