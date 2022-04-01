ancient_3_modifier_aura = class({})

function ancient_3_modifier_aura:IsHidden()
	return false
end

function ancient_3_modifier_aura:IsPurgable()
	return false
end

function ancient_3_modifier_aura:RemoveOnDeath()
	return true
end

function ancient_3_modifier_aura:GetPriority()
    return MODIFIER_PRIORITY_ULTRA
end

--------------------------------------------------------------------------------

function ancient_3_modifier_aura:IsAura()
	return true
end

function ancient_3_modifier_aura:GetModifierAura()
	return "ancient_3_modifier_aura_effect"
end

function ancient_3_modifier_aura:GetAuraRadius()
	return self:GetAbility():GetSpecialValueFor("radius")
end

function ancient_3_modifier_aura:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function ancient_3_modifier_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

-----------------------------------------------------------

function ancient_3_modifier_aura:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	local intervals = self.ability:GetSpecialValueFor("intervals")
	self.self_slow = self.ability:GetSpecialValueFor("self_slow")
	self.block_min = self.ability:GetSpecialValueFor("block_min")
	self.block_max = self.ability:GetSpecialValueFor("block_max")

	--self.parent:AddNewModifier(self.caster, self.ability, "_modifier_movespeed_debuff", {percent = self_slow})

	local leap = self.parent:FindAbilityByName("ancient_2__leap")
	if leap then
		if leap:IsTrained() then
			leap:SetCharges(5)
		end
	end

	if IsServer() then
		self:StartIntervalThink(intervals)
		self:PlayEfxStart()
		self:PlayEfxBuff()
	end
end

function ancient_3_modifier_aura:OnRefresh(kv)
end

function ancient_3_modifier_aura:OnRemoved()
	self.ability:StartCooldown(self.ability:GetEffectiveCooldown(self.ability:GetLevel()))
	self.ability:SetActivated(true)

	local leap = self.parent:FindAbilityByName("ancient_2__leap")
	if leap then
		if leap:IsTrained() then
			leap:SetCharges(1)
		end
	end
end

-----------------------------------------------------------

function ancient_3_modifier_aura:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK_SPECIAL
	}

	return funcs
end

function ancient_3_modifier_aura:GetModifierMoveSpeed_Limit()
	return self.self_slow
end

function ancient_3_modifier_aura:GetModifierPhysical_ConstantBlockSpecial()
	return RandomInt(self.block_min, self.block_max)
end

function ancient_3_modifier_aura:OnIntervalThink()
	self:PlayEfxStart()
end

-----------------------------------------------------------

function ancient_3_modifier_aura:GetStatusEffectName()
	return "particles/status_fx/status_effect_statue.vpcf"
end

function ancient_3_modifier_aura:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function ancient_3_modifier_aura:PlayEfxStart()
	local particle_cast = "particles/ancient/ancient_aura_pulses.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())

	if IsServer() then self.parent:EmitSound("Ancient.Aura.Layer") end
end

function ancient_3_modifier_aura:PlayEfxBuff()
	local particle_cast = "particles/items_fx/aura_endurance.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	self:AddParticle(effect_cast, false, false, -1, false, false)

	local particle = "particles/econ/items/pugna/pugna_ward_golden_nether_lord/pugna_gold_ambient.vpcf"
	self.effect_caster = ParticleManager:CreateParticle(particle, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_caster, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_caster, 1, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_caster, 2, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_caster, 4, self.parent:GetOrigin())
	self:AddParticle(self.effect_caster, false, false, -1, false, false)
end