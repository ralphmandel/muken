striker_2_modifier_burn_aura_effect = class({})

function striker_2_modifier_burn_aura_effect:IsHidden()
	return false
end

function striker_2_modifier_burn_aura_effect:IsPurgable()
	return false
end

function striker_2_modifier_burn_aura_effect:IsDebuff()
	return true
end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_2_modifier_burn_aura_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.intervals = 0.3
	self.damageTable = {
		victim = self.parent,
		attacker = self.caster,
		damage = 0,
		damage_type = DAMAGE_TYPE_MAGICAL,
		ability = self.ability
	}

	if IsServer() then
		self:StartIntervalThink(self.intervals)
		self:PlayEfxRadiance()
	end
end

function striker_2_modifier_burn_aura_effect:OnRefresh(kv)
end

function striker_2_modifier_burn_aura_effect:OnRemoved()
	if self.particle then ParticleManager:DestroyParticle(self.particle, false) end
end

-- API FUNCTIONS -----------------------------------------------------------

function striker_2_modifier_burn_aura_effect:OnIntervalThink()
	if self.particle then ParticleManager:SetParticleControl(self.particle, 1, self.caster:GetAbsOrigin()) end

	local damage = 20
	if self.parent:IsAttacking() then damage = 30 end
	self.damageTable.damage = self.intervals * damage
	ApplyDamage(self.damageTable)

	if IsServer() then self:StartIntervalThink(self.intervals) end
end

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function striker_2_modifier_burn_aura_effect:PlayEfxRadiance()
	if self.particle then ParticleManager:DestroyParticle(self.particle, false) end

	local string_2 = "particles/units/heroes/hero_phoenix/phoenix_supernova_radiance.vpcf"
	self.particle = ParticleManager:CreateParticle(string_2, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.particle, 0, self.parent:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.particle, 1, self.caster:GetAbsOrigin())
	self:AddParticle(self.particle, false, false, -1, false, false)
end