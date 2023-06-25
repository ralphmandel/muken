bocuse_5_modifier_pull = class({})

function bocuse_5_modifier_pull:IsHidden()
	return true
end

function bocuse_5_modifier_pull:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function bocuse_5_modifier_pull:OnCreated(kv)
	if not IsServer() then return end

  AddModifier(self:GetParent(), self:GetCaster(), self:GetAbility(), "_modifier_movespeed_buff", {percent = 150}, false)

	self:ApplyHorizontalMotionController()
	self:StartIntervalThink(0.034)
end

function bocuse_5_modifier_pull:OnRefresh(kv)
	self:OnCreated(kv)
end

function bocuse_5_modifier_pull:OnRemoved()
  RemoveAllModifiersByNameAndAbility(self.parent, "_modifier_movespeed_buff", self.ability)
end

function bocuse_5_modifier_pull:OnDestroy()
	if not IsServer() then return end
	self:GetParent():RemoveHorizontalMotionController(self)
end

--------------------------------------------------------------------------------

function bocuse_5_modifier_pull:OnIntervalThink()
	if not IsServer() then return end
	self:ApplyHorizontalMotionController()
	self:StartIntervalThink(0.034)
end

function bocuse_5_modifier_pull:UpdateHorizontalMotion(me, dt)
    local casterPos = self:GetParent():GetAbsOrigin()
	local center = Vector(self:GetAbility().point.x, self:GetAbility().point.y, 0)
    local direction = center - casterPos
    local vec = direction:Normalized() * 5

    self:GetParent():SetAbsOrigin(casterPos + vec)
	self:GetParent():RemoveHorizontalMotionController(self)
end

-- function bocuse_5_modifier_pull:OnHorizontalMotionInterrupted()
-- 	self:Destroy()
-- end