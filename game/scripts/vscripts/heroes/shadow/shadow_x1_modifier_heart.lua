shadow_x1_modifier_heart = class({})

function shadow_x1_modifier_heart:IsPurgable()
	return false
end

function shadow_x1_modifier_heart:IsHidden()
	return false
end

function shadow_x1_modifier_heart:IsDebuff()
	return true
end

-------------------------------------------------------------------

function shadow_x1_modifier_heart:OnCreated(kv)
	self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self:PlayEfxStart()
	self:StartIntervalThink(0.1)
end

function shadow_x1_modifier_heart:OnRefresh(kv)
end

function shadow_x1_modifier_heart:OnRemoved()
	if IsServer() then self.parent:EmitSound("Hero_PhantomAssassin.Strike.End") end
end

--------------------------------------------------------------------------------

function shadow_x1_modifier_heart:GetEffectName()
	return "particles/bioshadow/bioshadow_heart.vpcf"
end

function shadow_x1_modifier_heart:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function shadow_x1_modifier_heart:PlayEfxStart()
	if IsServer() then self.parent:EmitSound("Hero_Bloodseeker.BloodRite.Cast") end
end