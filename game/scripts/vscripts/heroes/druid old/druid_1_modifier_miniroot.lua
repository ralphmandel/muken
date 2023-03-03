druid_1_modifier_miniroot = class({})

function druid_1_modifier_miniroot:IsHidden()
	return true
end

function druid_1_modifier_miniroot:IsPurgable()
	return false
end

function druid_1_modifier_miniroot:IsDebuff()
	return false
end

function druid_1_modifier_miniroot:IsAura()
	return true
end

function druid_1_modifier_miniroot:GetModifierAura()
	return "druid_1_modifier_miniroot_effect"
end

function druid_1_modifier_miniroot:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function druid_1_modifier_miniroot:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function druid_1_modifier_miniroot:GetAuraRadius()
	return 30
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_1_modifier_miniroot:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:PlayEfxStart() end
end

function druid_1_modifier_miniroot:OnRefresh(kv)
end

function druid_1_modifier_miniroot:OnRemoved()
	RemoveFOWViewer(self.caster:GetTeamNumber(), self.fow)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function druid_1_modifier_miniroot:PlayEfxStart()
	local radius = self.ability:GetSpecialValueFor("radius")
	self.fow = AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), radius + 50, self:GetDuration(), false)

	local string = "particles/druid/druid_bush.vpcf"
	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
    ParticleManager:SetParticleControl(effect_cast, 10, Vector(self:GetDuration(), 0, 0 ))
	self:AddParticle(effect_cast, false, false, -1, false, false)
    
	if IsServer() then self.parent:EmitSound("Druid.Foot_" .. RandomInt(1, 3)) end
end