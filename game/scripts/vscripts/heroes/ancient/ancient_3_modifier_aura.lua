ancient_3_modifier_aura = class({})

function ancient_3_modifier_aura:IsHidden()
	return false
end

function ancient_3_modifier_aura:IsPurgable()
	return false
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
	if self:GetAbility():GetCurrentAbilityCharges() == 0 then return DOTA_UNIT_TARGET_TEAM_ENEMY end
	if self:GetAbility():GetCurrentAbilityCharges() == 1 then return DOTA_UNIT_TARGET_TEAM_ENEMY end
	if self:GetAbility():GetCurrentAbilityCharges() % 2 == 0 then return DOTA_UNIT_TARGET_TEAM_BOTH end
	return DOTA_UNIT_TARGET_TEAM_ENEMY 
end

function ancient_3_modifier_aura:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function ancient_3_modifier_aura:GetAbilityTargetFlags()
	return DOTA_UNIT_TARGET_FLAG_NO_INVIS
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
	self.ms_boost = 0
	self.ability.find = false
	self.stun_immunity = false

	-- UP 3.11
	if self.ability:GetRank(11) then
		self.ms_boost = 100
	end

	-- UP 3.21
	if self.ability:GetRank(21) then
		self.stun_immunity = true
	end

	-- UP 3.22
	if self.ability:GetRank(22) then
		self.block_max = self.block_max + 20
	end

	-- UP 3.41
	if self.ability:GetRank(41) then
		self:ApplyHeal(50, 100)
	end

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

function ancient_3_modifier_aura:CheckState()
	local state = {}

	if self.stun_immunity == true then
		state = {
			[MODIFIER_STATE_STUNNED] = false,
			[MODIFIER_STATE_FROZEN] = false
		}
	end

	return state
end

function ancient_3_modifier_aura:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK_SPECIAL
	}

	return funcs
end

function ancient_3_modifier_aura:GetModifierMoveSpeed_Limit()
	if self.ability.find == false then
		return self.self_slow +  self.ms_boost
	end

	return self.self_slow
end

function ancient_3_modifier_aura:GetModifierPhysical_ConstantBlockSpecial()
	return RandomInt(self.block_min, self.block_max)
end

function ancient_3_modifier_aura:OnIntervalThink()
	self:PlayEfxStart()

	-- UP 3.41
	if self.ability:GetRank(41) then
		self:ApplyHeal(10, 25)
	end
end

function ancient_3_modifier_aura:ApplyHeal(heal, chance)
	local mnd = self.caster:FindModifierByName("_2_MND_modifier")
	if mnd then heal = heal * mnd:GetHealPower() end

	local allies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.ability:GetSpecialValueFor("radius"),
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		0, 0, false
	)

	for _,ally in pairs(allies) do
		ally:Heal(heal, self.ability)
		self:PlayEfxHeal(ally)

		if RandomInt(1, 100) <= chance then
			ally:Purge(false, true, false, false, false)
		end
	end
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

	if IsServer() then
		self.parent:EmitSound("Ancient.Aura.Layer")
		self.parent:EmitSound("Hero_EarthShaker.Totem.Attack.Immortal.Layer")
	end
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

function ancient_3_modifier_aura:PlayEfxHeal(unit)
	local particle_cast = "particles/units/heroes/hero_omniknight/omniknight_shard_hammer_of_purity_heal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, unit)
	ParticleManager:SetParticleControl(effect_cast, 0, unit:GetOrigin())
end