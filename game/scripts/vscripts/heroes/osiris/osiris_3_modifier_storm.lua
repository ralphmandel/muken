osiris_3_modifier_storm = class({})

function osiris_3_modifier_storm:IsHidden()
	return true
end

function osiris_3_modifier_storm:IsPurgable()
	return false
end

function osiris_3_modifier_storm:IsDebuff()
	return false
end

-- AURA -----------------------------------------------------------

function osiris_3_modifier_storm:IsAura()
	return true
end

function osiris_3_modifier_storm:GetModifierAura()
	return "osiris_3_modifier_aura_effect"
end

function osiris_3_modifier_storm:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

function osiris_3_modifier_storm:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_CREEP
end

function osiris_3_modifier_storm:GetAuraRadius()
	return self:GetAbility():GetAOERadius()
end

-- CONSTRUCTORS -----------------------------------------------------------

function osiris_3_modifier_storm:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:PlayEfxStart() end
end

function osiris_3_modifier_storm:OnRefresh(kv)
end

function osiris_3_modifier_storm:OnRemoved()
	self.ability.mod_thinker = nil

	if self.effect_cast then
		ParticleManager:DestroyParticle(self.effect_cast, false)
		ParticleManager:ReleaseParticleIndex(self.effect_cast)
	end

	if IsServer() then self.parent:StopSound("Ability.SandKing_SandStorm.loop") end
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function osiris_3_modifier_storm:PlayEfxStart()
	local radius = self.ability:GetAOERadius()
	--local particle_cast = "particles/osiris/sandstorm/osiris_desert_sands_ambient_loadout.vpcf"
	local particle_cast = "particles/units/heroes/hero_sandking/sandking_sandstorm.vpcf"
	self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, self.caster)
	ParticleManager:SetParticleControl(self.effect_cast, 0, self.caster:GetAbsOrigin())
	ParticleManager:SetParticleControl(self.effect_cast, 1, Vector(radius, radius, 0))
	self:AddParticle(self.effect_cast, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Ability.SandKing_SandStorm.loop") end
end