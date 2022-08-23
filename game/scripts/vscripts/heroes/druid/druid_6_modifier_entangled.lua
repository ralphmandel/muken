druid_6_modifier_entangled = class({})

function druid_6_modifier_entangled:IsHidden()
	return false
end

function druid_6_modifier_entangled:IsPurgable()
	return true
end

function druid_6_modifier_entangled:IsDebuff()
	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_6_modifier_entangled:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.interval = self.ability:GetSpecialValueFor("interval")
	self.damage_reduction = self.ability:GetSpecialValueFor("damage_reduction")
	self.max_targets = self.ability:GetSpecialValueFor("max_targets")
	self.leech_amount = self.ability:GetSpecialValueFor("leech_amount")

	if IsServer() then
		self:StartIntervalThink(self.interval - 0.1)
		self:PlayEfxStart()
	end
end

function druid_6_modifier_entangled:OnRefresh(kv)
end

function druid_6_modifier_entangled:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function druid_6_modifier_entangled:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = true
	}

	return state
end

function druid_6_modifier_entangled:DeclareFunctions()
	local funcs = {
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_PROPERTY_INCOMING_DAMAGE_PERCENTAGE
	}

	return funcs
end

function druid_6_modifier_entangled:GetOverrideAnimation()
	return ACT_DOTA_FLAIL
end

function druid_6_modifier_entangled:GetModifierIncomingDamage_Percentage(keys)
	return -self.damage_reduction
end

function druid_6_modifier_entangled:OnIntervalThink()
	self:ApplyLeech()

	if IsServer() then self:StartIntervalThink(self.interval) end
end

-- UTILS -----------------------------------------------------------

function druid_6_modifier_entangled:ApplyLeech()
	self.damage_reduction = 0
	local targets = self.max_targets
	local units = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.ability:GetAOERadius(),
		DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false
	)

	for _,unit in pairs(units) do
		if self.parent:IsAlive() and targets > 0 then
			self.ability:CreateSeedProj(unit, self.parent, self.leech_amount)

			targets = targets - 1

			ApplyDamage({
				damage = self.leech_amount, attacker = self.caster, victim = self.parent,
				damage_type = self.ability:GetAbilityDamageType(), ability = self.ability
			})
		end
	end

	self.damage_reduction = self.ability:GetSpecialValueFor("damage_reduction")
	self:PlayEfxLeech()
end
-- EFFECTS -----------------------------------------------------------

function druid_6_modifier_entangled:PlayEfxStart()
	local string = "particles/econ/items/lone_druid/lone_druid_cauldron_retro/lone_druid_bear_entangle_retro_cauldron.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	self:AddParticle(particle, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_Treant.LeechSeed.Target") end
end

function druid_6_modifier_entangled:PlayEfxLeech()
	local string = "particles/units/heroes/hero_treant/treant_leech_seed_damage_pulse.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle)

	if IsServer() then self.parent:EmitSound("Hero_Treant.LeechSeed.Tick") end
end