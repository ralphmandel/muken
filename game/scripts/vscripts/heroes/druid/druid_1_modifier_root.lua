druid_1_modifier_root = class({})

function druid_1_modifier_root:IsHidden()
	return true
end

function druid_1_modifier_root:IsPurgable()
	return false
end

function druid_1_modifier_root:IsDebuff()
	return false
end

function druid_1_modifier_root:IsAura()
	return true
end

function druid_1_modifier_root:GetModifierAura()
	return "druid_1_modifier_root_effect"
end

function druid_1_modifier_root:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_ENEMY
end

function druid_1_modifier_root:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function druid_1_modifier_root:GetAuraRadius()
	return 50
end

-- CONSTRUCTORS -----------------------------------------------------------

function druid_1_modifier_root:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:PlayEfxStart(kv.type) end
end

function druid_1_modifier_root:OnRefresh(kv)
end

function druid_1_modifier_root:OnRemoved()
	RemoveFOWViewer(self.caster:GetTeamNumber(), self.fow)
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function druid_1_modifier_root:PlayEfxStart(type)
	local radius = self.ability:GetSpecialValueFor("radius")
	self.fow = AddFOWViewer(self.caster:GetTeamNumber(), self.parent:GetOrigin(), radius + 50, self:GetDuration(), false)

	local string = "particles/druid/druid_skill2_ground_root.vpcf"
	if type == 2 then string = "particles/druid/druid_bush.vpcf" end

	local effect_cast = ParticleManager:CreateParticle(string, PATTACH_ABSORIGIN, self.caster)
	ParticleManager:SetParticleControl(effect_cast, 0, self.parent:GetOrigin())
    ParticleManager:SetParticleControl(effect_cast, 10, Vector(self:GetDuration(), 0, 0 ))
	self:AddParticle(effect_cast, false, false, -1, false, false)
    
	if IsServer() then self.parent:EmitSound("Druid.Bramble_" .. RandomInt(1, 3)) end
end