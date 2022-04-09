bocuse_x2_modifier_mirepoix = class ({})

function bocuse_x2_modifier_mirepoix:IsHidden()
    return false
end

function bocuse_x2_modifier_mirepoix:IsPurgable()
    return false
end

-----------------------------------------------------------

function bocuse_x2_modifier_mirepoix:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local resistance = self.ability:GetSpecialValueFor("resistance")
	self.init_model_scale = self.ability:GetSpecialValueFor("init_model_scale")
	self.max_range = self.ability:GetSpecialValueFor("max_range") * 100
    self.range = 0

	self.ability:AddBonus("_2_RES", self.parent, resistance, 0, nil)
	self.parent:StartGesture(ACT_DOTA_TELEPORT_END)
	self:StartIntervalThink(FrameTime())
    self:PlayEfxStart()
end

function bocuse_x2_modifier_mirepoix:OnRefresh(kv)
end

function bocuse_x2_modifier_mirepoix:OnRemoved()
	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
	self.ability:SetActivated(true)
	self.ability:RemoveBonus("_2_RES", self.parent)

	self.parent:AddNewModifier(self.caster, self.ability, "bocuse_x2_modifier_end", {
		duration = 2,
		range = self.range
	})
end

-----------------------------------------------------------

function bocuse_x2_modifier_mirepoix:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
	
	return funcs
end

function bocuse_x2_modifier_mirepoix:GetModifierAttackRangeBonus()
    return self.range * 0.016
end

function bocuse_x2_modifier_mirepoix:OnIntervalThink()
	self.range = self.range + 125
	local model_scale = self.init_model_scale * (1 + (self.range * 0.00005))
	self.parent:SetModelScale(model_scale)
	self.parent:SetHealthBarOffsetOverride(200 * self.parent:GetModelScale())
	if self.range >= self.max_range then
		self:StartIntervalThink(-1)
	end
end

------------------------------------------------------------

function bocuse_x2_modifier_mirepoix:PlayEfxStart()
	local paticle = "particles/econ/items/wisp/wisp_relocate_teleport_ti7_out.vpcf"
	local effect_cast = ParticleManager:CreateParticle(paticle, PATTACH_POINT_FOLLOW, self.parent)

	if IsServer() then self.parent:EmitSound("DOTA_Item.BlackKingBar.Activate") end
end

function bocuse_x2_modifier_mirepoix:GetEffectName()
	return "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_secondstyle_debuff.vpcf"
end

function bocuse_x2_modifier_mirepoix:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end