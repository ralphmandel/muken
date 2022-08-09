bocuse_4_modifier_enhance = class ({})

function bocuse_4_modifier_enhance:IsHidden()
    return false
end

function bocuse_4_modifier_enhance:IsPurgable()
    return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function bocuse_4_modifier_enhance:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self.init_model_scale = self.ability:GetSpecialValueFor("init_model_scale")
	self.atk_range_bonus = self.ability:GetSpecialValueFor("atk_range_bonus") * 100
    self.range = 0

	if IsServer() then
		self.parent:StartGesture(ACT_DOTA_TELEPORT_END)
		self:StartIntervalThink(FrameTime())
		self:PlayEfxStart()
	end
end

function bocuse_4_modifier_enhance:OnRefresh(kv)
end

function bocuse_4_modifier_enhance:OnRemoved()
	self.ability:RemoveBonus("_1_CON", self.parent)
	self.ability:RemoveBonus("_1_AGI", self.parent)
	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
	self.ability:SetActivated(true)

	if self.parent:IsAlive() then
		self.parent:AddNewModifier(self.caster, self.ability, "bocuse_4_modifier_end", {
			duration = 2,
			range = self.range
		})
	else
		self.parent:SetModelScale(self.init_model_scale)
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function bocuse_4_modifier_enhance:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_ATTACK_RANGE_BONUS,
	}
	
	return funcs
end

function bocuse_4_modifier_enhance:GetModifierAttackRangeBonus()
    return self.range * 0.016
end

function bocuse_4_modifier_enhance:OnIntervalThink()
	self.range = self.range + 125
	local model_scale = self.init_model_scale * (1 + (self.range * 0.00005))
	self.parent:SetModelScale(model_scale)
	self.parent:SetHealthBarOffsetOverride(200 * self.parent:GetModelScale())
	if self.range >= self.atk_range_bonus then
		self:AddEffects()
		self:StartIntervalThink(-1)
	end
end

-- UTILS -----------------------------------------------------------

function bocuse_4_modifier_enhance:AddEffects()
	local con = self.ability:GetSpecialValueFor("con")
	local agi = self.ability:GetSpecialValueFor("agi")

	self.ability:AddBonus("_1_CON", self.parent, con, 0, nil)
	self.ability:AddBonus("_1_AGI", self.parent, agi, 0, nil)
end

-- EFFECTS -----------------------------------------------------------

function bocuse_4_modifier_enhance:GetEffectName()
	return "particles/econ/items/ogre_magi/ogre_magi_arcana/ogre_magi_arcana_ignite_secondstyle_debuff.vpcf"
end

function bocuse_4_modifier_enhance:GetEffectAttachType()
	return PATTACH_POINT_FOLLOW
end

function bocuse_4_modifier_enhance:PlayEfxStart()
	local paticle = "particles/econ/items/wisp/wisp_relocate_teleport_ti7_out.vpcf"
	local effect_cast = ParticleManager:CreateParticle(paticle, PATTACH_POINT_FOLLOW, self.parent)

	if IsServer() then self.parent:EmitSound("DOTA_Item.BlackKingBar.Activate") end
end