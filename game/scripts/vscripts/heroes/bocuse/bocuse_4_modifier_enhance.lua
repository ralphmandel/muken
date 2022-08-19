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

	-- UP 4.21
	if self.ability:GetRank(21) then
		self.parent:AddNewModifier(self.caster, self.ability, "_modifier_bkb", {duration = self:GetDuration() * 0.3})
	end

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
	self:ModifyCastRange(self.parent:FindAbilityByName("bocuse_1__cut"), 1)
	self:ModifyCastRange(self.parent:FindAbilityByName("bocuse_2__flask"), 1)

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
		MODIFIER_EVENT_ON_ATTACKED
	}
	
	return funcs
end

function bocuse_4_modifier_enhance:GetModifierAttackRangeBonus()
    return self.range * 0.016
end

function bocuse_4_modifier_enhance:OnAttacked(keys)
	if keys.attacker ~= self.parent then return end

	-- UP 4.31
	if self.ability:GetRank(31) then
		local heal = keys.original_damage * 0.25
		keys.attacker:Heal(heal, self.ability)
		self:PlayEfxLifesteal(keys.attacker)
	end
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

	-- UP 4.11
	if self.ability:GetRank(11) then
		con = con + 10
	end

	self.ability:AddBonus("_1_CON", self.parent, con, 0, nil)
	self.ability:AddBonus("_1_AGI", self.parent, agi, 0, nil)

	self:ModifyCastRange(self.parent:FindAbilityByName("bocuse_1__cut"), 7)
	self:ModifyCastRange(self.parent:FindAbilityByName("bocuse_2__flask"), 7)
	self:ModifyCastRange(self.parent:FindAbilityByName("bocuse_5__puddle"), 7)
end

function bocuse_4_modifier_enhance:ModifyCastRange(ability, charges)
	if ability == nil then return end
	if ability:IsTrained() == false then return end

	ability.base_charges = charges
	ability:CheckAbilityCharges(ability.base_charges)
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

function bocuse_4_modifier_enhance:PlayEfxLifesteal(attacker)
	local particle_cast = "particles/units/heroes/hero_skeletonking/wraith_king_vampiric_aura_lifesteal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, attacker)
	ParticleManager:SetParticleControl(effect_cast, 1, attacker:GetOrigin())
	ParticleManager:ReleaseParticleIndex(effect_cast)
end