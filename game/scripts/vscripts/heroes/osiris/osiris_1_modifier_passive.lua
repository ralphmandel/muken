osiris_1_modifier_passive = class({})

function osiris_1_modifier_passive:IsHidden()
	return true
end

function osiris_1_modifier_passive:IsPurgable()
	return false
end

function osiris_1_modifier_passive:IsDebuff()
	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function osiris_1_modifier_passive:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.hp = self.ability:GetSpecialValueFor("hp")
	self.poison_radius = self.ability:GetSpecialValueFor("poison_radius")
	self.current_hp = 0
end

function osiris_1_modifier_passive:OnRefresh(kv)
end

function osiris_1_modifier_passive:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

function osiris_1_modifier_passive:DeclareFunctions()
	local funcs = {
		MODIFIER_EVENT_ON_TAKEDAMAGE
	}

	return funcs
end

function osiris_1_modifier_passive:OnTakeDamage(keys)
	if keys.unit ~= self.parent then return end
	self.current_hp = self.current_hp + keys.damage

	if self.current_hp >= self.hp then
		self.current_hp = 0
		self:Release()
	end
end

-- UTILS -----------------------------------------------------------

function osiris_1_modifier_passive:Release()
	local poison_duration = self.ability:GetSpecialValueFor("poison_duration")
	self.parent:Purge(false, true, false, false, false)
	self:PlayEfxRelease()

	local enemies = FindUnitsInRadius(
		self.caster:GetTeamNumber(), self.parent:GetOrigin(), nil, self.poison_radius,
		DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC,
		DOTA_UNIT_TARGET_FLAG_NONE, FIND_ANY_ORDER, false
	)

	for _,enemy in pairs(enemies) do
		enemy:AddNewModifier(self.caster, self.ability, "osiris_1_modifier_poison", {
			duration = self.ability:CalcStatus(poison_duration, self.caster, self.parent)
		})
	end
end

-- EFFECTS -----------------------------------------------------------

function osiris_1_modifier_passive:PlayEfxRelease()
	-- local particle_cast = "particles/units/heroes/hero_venomancer/venomancer_poison_nova.vpcf"
	-- local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_ABSORIGIN_FOLLOW, self.parent)
	-- ParticleManager:SetParticleControl(effect_cast, 1, Vector(100, 0.5, 100))
	-- ParticleManager:ReleaseParticleIndex(effect_cast)

	local string = "particles/osiris/osiris_poison.vpcf"
	local particle = ParticleManager:CreateParticle(string, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(particle, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(particle, 1, self.parent:GetOrigin())
	ParticleManager:ReleaseParticleIndex(particle)

	if IsServer() then self.parent:EmitSound("Hero_Venomancer.VenomousGale") end
end