
striker_5_modifier_trail = class({})

function striker_5_modifier_trail:IsHidden()
	return true
end

function striker_5_modifier_trail:IsDebuff()
	return false
end

function striker_5_modifier_trail:IsPurgable()
	return false
end

-- AURA -----------------------------------------------------------

function striker_5_modifier_trail:IsAura()
	return true
end

function striker_5_modifier_trail:GetModifierAura()
	return "striker_5_modifier_debuff"
end

function striker_5_modifier_trail:GetAuraRadius()
	return self.radius
end

function striker_5_modifier_trail:GetAuraDuration()
	return 0.5
end

function striker_5_modifier_trail:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function striker_5_modifier_trail:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function striker_5_modifier_trail:GetAuraSearchFlags()
	return 0
end

-- CONSTRUCTORS -----------------------------------------------------------

function striker_5_modifier_trail:OnCreated(kv)
	self.radius = 175
	self.prev_pos = Vector(kv.x, kv.y, 0)
	self.prev_pos = GetGroundPosition(self.prev_pos, self:GetParent())

	self:PlayEfxStart(kv.duration)
end

function striker_5_modifier_trail:OnRefresh(kv)
end

function striker_5_modifier_trail:OnRemoved()
end

function striker_5_modifier_trail:OnDestroy()
	if not IsServer() then return end
	UTIL_Remove(self:GetParent())
end

-- EFFECTS -----------------------------------------------------------

function striker_5_modifier_trail:PlayEfxStart(duration)
	local particle_cast = "particles/units/heroes/hero_dawnbreaker/dawnbreaker_converge_burning_trail.vpcf"
	local effect_cast = ParticleManager:CreateParticle( particle_cast, PATTACH_WORLDORIGIN, self:GetParent())
	ParticleManager:SetParticleControl(effect_cast, 0, self:GetParent():GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 1, self.prev_pos)
	ParticleManager:SetParticleControl(effect_cast, 2, Vector(duration, 0, 0 ))
	ParticleManager:SetParticleControl(effect_cast, 3, Vector(self.radius, self.radius, self.radius ))
	ParticleManager:ReleaseParticleIndex(effect_cast)
end