bocuse_5_modifier_puddle = class({})

function bocuse_5_modifier_puddle:IsHidden()
	return true
end

function bocuse_5_modifier_puddle:IsPurgable()
	return false
end

--------------------------------------------------------------------------------

function bocuse_5_modifier_puddle:IsAura()
	return true
end

function bocuse_5_modifier_puddle:GetModifierAura()
	return "bocuse_5_modifier_aura_effect"
end

function bocuse_5_modifier_puddle:GetAuraRadius()
	return self.ability:GetAOERadius()
end

function bocuse_5_modifier_puddle:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function bocuse_5_modifier_puddle:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

-----------------------------------------------------------

function bocuse_5_modifier_puddle:OnCreated(kv)
    self.caster = self:GetCaster()
	self.parent = self:GetParent()
	self.ability = self:GetAbility()

	self:PlayEfxStart()
end

function bocuse_5_modifier_puddle:OnRefresh(kv)
end

function bocuse_5_modifier_puddle:OnRemoved()
	self:PlayEfxFinal()
end

-----------------------------------------------------------

function bocuse_5_modifier_puddle:PlayEfxStart()
	local radius = self.ability:GetAOERadius()
	AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), radius, self:GetDuration() + 1, false)

	local particle_cast = "particles/bocuse/bocuse_roux_aoe_mass.vpcf"
	self.effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(self.effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(self.effect_cast, 10, Vector(radius, radius, radius))

    if IsServer() then self.parent:EmitSound("Brewmaster_Storm.Cyclone") end
end

function bocuse_5_modifier_puddle:PlayEfxFinal()
	local radius = self.ability:GetAOERadius()

    local particle_cast = "particles/units/heroes/hero_sandking/sandking_epicenter.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_POINT_FOLLOW, self.parent)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, Vector(radius, radius, radius))

    if IsServer() then
        self.parent:EmitSound("Hero_EarthSpirit.StoneRemnant.Impact")
        self.parent:StopSound("Brewmaster_Storm.Cyclone")
    end
end