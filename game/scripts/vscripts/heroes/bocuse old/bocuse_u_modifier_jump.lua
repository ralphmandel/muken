bocuse_u_modifier_jump = class ({})

function bocuse_u_modifier_jump:IsHidden()
    return true
end

function bocuse_u_modifier_jump:IsPurgable()
    return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_u_modifier_jump:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self:StartIntervalThink(FrameTime())
	self.angle = self.parent:GetForwardVector():Normalized()
	self.distance = 600 / (self:GetDuration() / FrameTime())
end

function bocuse_u_modifier_jump:OnRefresh(kv)
end

function bocuse_u_modifier_jump:OnRemoved()
end

function bocuse_u_modifier_jump:OnDestroy()
	if not IsServer() then return end
	ResolveNPCPositions(self.parent:GetAbsOrigin(), 128)
	self.parent:MoveToPosition(self.parent:GetOrigin())
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_u_modifier_jump:OnIntervalThink()
	self:HorizontalMotion(self.parent, FrameTime())
end

function bocuse_u_modifier_jump:HorizontalMotion(unit, time)
	if not IsServer() then return end

	local pos = unit:GetAbsOrigin()
	GridNav:DestroyTreesAroundPoint(pos, 80, false)
	local pos_p = self.angle * self.distance
	local next_pos = GetGroundPosition(pos + pos_p,unit)
	unit:SetAbsOrigin(next_pos)

    local units = FindUnitsInRadius(
        self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, 50,
        DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0, 0, false
    )

    for _,unit in pairs(units) do
        self:Destroy()
    end
end