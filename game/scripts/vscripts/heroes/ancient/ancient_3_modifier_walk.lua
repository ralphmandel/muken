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

function ancient_3_modifier_walk:GetPriority()
    return MODIFIER_PRIORITY_ULTRA
end

-- CONSTRUCTORS -----------------------------------------------------------

function ancient_3_modifier_walk:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()
	self.stun_immunity = false

	self.max_ms = self.ability:GetSpecialValueFor("max_ms")

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "ancient_3_modifier_walk_status_efx", true) end

	-- UP 3.31
	if self.ability:GetRank(31) then
		self.stun_immunity = true
	end

	local leap = self.parent:FindAbilityByName("ancient_2__leap")
	if leap then leap:CheckAbilityCharges(1) end

	if IsServer() then self:OnIntervalThink() end
end

function ancient_3_modifier_walk:OnRefresh(kv)
end

function ancient_3_modifier_walk:OnRemoved()
	self.ability:SetActivated(true)

	local leap = self.parent:FindAbilityByName("ancient_2__leap")
	if leap then leap:CheckAbilityCharges(1) end

	local cosmetics = self.parent:FindAbilityByName("cosmetics")
	if cosmetics then cosmetics:SetStatusEffect(self.caster, self.ability, "ancient_3_modifier_walk_status_efx", false) end
end

-- API FUNCTIONS -----------------------------------------------------------

function ancient_3_modifier_walk:CheckState()
	local state = {}

	if self.stun_immunity == true then
		state = {
			[MODIFIER_STATE_STUNNED] = false,
			[MODIFIER_STATE_FROZEN] = false
		}
	end

	return state
end

function ancient_3_modifier_walk:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_HP_REGEN_AMPLIFY_PERCENTAGE,
		MODIFIER_PROPERTY_MOVESPEED_LIMIT,
		MODIFIER_PROPERTY_PHYSICAL_CONSTANT_BLOCK
	}
	
	return funcs
end

function ancient_3_modifier_walk:GetModifierHPRegenAmplify_Percentage()
    return -99999
end

function ancient_3_modifier_walk:GetModifierMoveSpeed_Limit()
	return self.max_ms
end

function ancient_3_modifier_walk:GetModifierPhysical_ConstantBlock(keys)
	if keys.attacker == nil then return end
	if keys.attacker:IsBaseNPC() == false then return end
	local base_stats_attacker = keys.attacker:FindAbilityByName("base_stats")
	local block = self.ability:GetSpecialValueFor("block") * 0.01

	if IsServer() then self.parent:EmitSound("Generic.Petrified.Block") end

	-- UP 3.11
	if self.ability:GetRank(11)
	and RandomFloat(1, 100) <= 25 then
		if base_stats_attacker then
			if base_stats_attacker.has_crit == true then
				return keys.damage
			end
		end
	end

	return keys.damage * block
end

function ancient_3_modifier_walk:OnIntervalThink()
	self:ApplyDebuff()

	-- UP 3.21
	if self.ability:GetRank(21) then
		self:ApplyHeal()
	end

	-- UP 3.41
	if self.ability:GetRank(41) then
		self:ApplyAvatar()
	end

	if IsServer() then
		self:PlayEfxTick()
		self:StartIntervalThink(self.ability:GetSpecialValueFor("tick"))
	end
end

-- UTILS -----------------------------------------------------------

function ancient_3_modifier_walk:ApplyDebuff()
	local debuff_duration = self.ability:GetSpecialValueFor("debuff_duration")

	local units = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.ability:GetAOERadius(),
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false
	)

	for _,unit in pairs(units) do
		unit:AddNewModifier(self.caster, self.ability, "ancient_3_modifier_debuff", {
			duration = self.ability:CalcStatus(debuff_duration, self.caster, unit)
		})
	end
end

function ancient_3_modifier_walk:ApplyHeal()
	local total_heal = 0
	local heal = 10

	local base_stats = self.caster:FindAbilityByName("base_stats")
	if base_stats then heal = heal * base_stats:GetHealPower() end

	local allies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.ability:GetAOERadius(),
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO,
		DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false
	)

	for _,ally in pairs(allies) do
		if ally ~= self.parent then
			ally:Heal(heal, self.ability)
			self:PlayEfxHeal(ally)
			total_heal = total_heal + heal
		end
	end

	if total_heal > 0 then
		self.parent:Heal(total_heal, self.ability)
		self:PlayEfxHeal(self.parent)
	end
end

function ancient_3_modifier_walk:ApplyAvatar()
	local allies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.ability:GetAOERadius(),
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP,
		DOTA_DAMAGE_FLAG_NONE, FIND_ANY_ORDER, false
	)

	for _,ally in pairs(allies) do
		if ally ~= self.parent
		and RandomFloat(1, 100) <= 20 then
			ally:AddNewModifier(self.caster, self.ability, "ancient_3_modifier_avatar", {
				duration = self.ability:CalcStatus(3.5, self.caster, ally)
			})			
		end
	end
end

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

function ancient_3_modifier_walk:PlayEfxTick()
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