ancient_3_modifier_walk = class ({})

function ancient_3_modifier_walk:IsHidden()
    return false
end

function ancient_3_modifier_walk:IsPurgable()
    return false
end

function ancient_3_modifier_walk:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_3_modifier_walk:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	local block = self.ability:GetSpecialValueFor("block")
	self.max_ms = self.ability:GetSpecialValueFor("max_ms")

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "ancient_3_modifier_walk_status_efx", true) end

	self.parent:AddNewModifier(self.caster, self.ability, "base_stats_mod_block_bonus", {
		physical_block_min_percent = block,
		physical_block_max_percent = block
	})

	if IsServer() then self:OnIntervalThink() end
end

function ancient_3_modifier_walk:OnRefresh(kv)
end

function ancient_3_modifier_walk:OnRemoved()
	self.ability:SetActivated(true)

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "ancient_3_modifier_walk_status_efx", false) end

	local mod = self.parent:FindAllModifiersByName("base_stats_mod_block_bonus")
	for _,modifier in pairs(mod) do
		if modifier:GetAbility() == self.ability then modifier:Destroy() end
	end
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_3_modifier_walk:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT
	}
	
	return funcs
end

function ancient_3_modifier_walk:GetModifierHPRegenAmplify_Percentage()
    return -99999
end

function ancient_3_modifier_walk:GetModifierMoveSpeed_Limit()
	return self.max_ms
end

function ancient_3_modifier_walk:OnIntervalThink()
	local radius = self.ability:GetSpecialValueFor("radius")
	local debuff_duration = self.ability:GetSpecialValueFor("debuff_duration")

	local units = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false
	)

	for _,unit in pairs(units) do
		unit:AddNewModifier(self.caster, self.ability, "ancient_3_modifier_debuff", {
			duration = self.ability:CalcStatus(debuff_duration, self.caster, unit)
		})
	end

	if IsServer() then
		self:PlayEfxTick(radius)
		self:StartIntervalThink(self.ability:GetSpecialValueFor("tick"))
	end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function ancient_3_modifier_walk:GetStatusEffectName()
	return "particles/status_fx/status_effect_statue.vpcf"
end

function ancient_3_modifier_walk:StatusEffectPriority()
	return MODIFIER_PRIORITY_SUPER_ULTRA
end

function ancient_3_modifier_walk:PlayEfxStart()
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

function ancient_3_modifier_walk:PlayEfxTick(radius)
	local particle_cast = "particles/ancient/ancient_aura_pulses.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 1, self.parent:GetOrigin())

	if IsServer() then
		self.parent:EmitSound("Ancient.Aura.Layer")
		self.parent:EmitSound("Hero_EarthShaker.Totem.Attack.Immortal.Layer")
	end
end

function ancient_3_modifier_walk:PlayEfxHeal(unit)
	local particle_cast = "particles/units/heroes/hero_omniknight/omniknight_shard_hammer_of_purity_heal.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, unit)
	ParticleManager:SetParticleControl(effect_cast, 0, unit:GetOrigin())
end