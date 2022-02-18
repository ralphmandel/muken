icebreaker_u_modifier_blur = class({})

function icebreaker_u_modifier_blur:IsHidden()
	return true
end

function icebreaker_u_modifier_blur:IsPurgable()
    return false
end

-----------------------------------------------------------

function icebreaker_u_modifier_blur:OnCreated( kv )
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
end

function icebreaker_u_modifier_blur:OnRefresh( kv )
end

function icebreaker_u_modifier_blur:OnRemoved()
end

----------------------------------------------------------------------------

function icebreaker_u_modifier_blur:GetEffectName()
	return "particles/icebreaker/icebreaker_blur.vpcf"
end

function icebreaker_u_modifier_blur:GetEffectAttachType()
	return PATTACH_ABSORIGIN_FOLLOW
end