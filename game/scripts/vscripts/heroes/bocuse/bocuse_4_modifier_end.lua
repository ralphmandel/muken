bocuse_4_modifier_end = class ({})

function bocuse_4_modifier_end:IsHidden()
    return true
end

function bocuse_4_modifier_end:IsPurgable()
    return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_4_modifier_end:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.init_model_scale = self.ability:GetSpecialValueFor("init_model_scale")
    self.range = kv.range

	if IsServer() then
		self:StartIntervalThink(FrameTime())
		self:PlayEfxStart()
	end
end

function bocuse_4_modifier_end:OnRefresh(kv)
end

function bocuse_4_modifier_end:OnRemoved()
	self.parent:SetModelScale(self.init_model_scale)
	self.parent:SetHealthBarOffsetOverride(200 * self.parent:GetModelScale())
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_4_modifier_end:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
	
	return funcs
end

function bocuse_4_modifier_end:GetModifierAttackRangeBonus()
    return self.range * 0.016
end

function bocuse_4_modifier_end:OnIntervalThink()
	if self.range <= 0 then
		self.parent:SetModelScale(self.init_model_scale)
		self.parent:SetHealthBarOffsetOverride(200 * self.parent:GetModelScale())
		self:Destroy()
		self:StartIntervalThink(-1)
		return
	end

	self.range = self.range - 125
	local model_scale = self.init_model_scale * (1 + (self.range * 0.00005))
	self.parent:SetModelScale(model_scale)
	self.parent:SetHealthBarOffsetOverride(200 * self.parent:GetModelScale())
	if self.range <= 0 then
		self:Destroy()
		self:StartIntervalThink(-1)
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function bocuse_4_modifier_end:GetEffectName()
	return "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_secondstyle_debuff.vpcf"
end

function bocuse_4_modifier_end:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function bocuse_4_modifier_end:PlayEfxStart()
	local paticle = "particles/econ/items/wisp/wisp_relocate_teleport_ti7_out.vpcf"
	local effect_cast = ParticleManager:CreateParticle(paticle, PATTACH_POINT_FOLLOW, self.parent)

	if IsServer() then self.parent:EmitSound("DOTA_Item.BlackKingBar.Activate") end
end