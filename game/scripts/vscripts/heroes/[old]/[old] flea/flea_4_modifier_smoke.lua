flea_4_modifier_smoke = class({})

function flea_4_modifier_smoke:IsHidden() return true end
function flea_4_modifier_smoke:IsPurgable() return false end

-- AURA -----------------------------------------------------------

function flea_4_modifier_smoke:IsAura()
	return true
end

function flea_4_modifier_smoke:GetModifierAura()
	return "flea_4_modifier_smoke_effect"
end

function flea_4_modifier_smoke:GetAuraRadius()
	return self:GetAbility():GetAOERadius()
end

function flea_4_modifier_smoke:GetAuraSearchTeam()
	return DOTA_UNIT_TARGET_TEAM_BOTH
end

function flea_4_modifier_smoke:GetAuraSearchType()
	return DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC
end

function flea_4_modifier_smoke:GetAuraSearchFlags()
	return DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
end

function flea_4_modifier_smoke:GetAuraEntityReject(hEntity)
	if self:GetCaster() == hEntity and self:GetAbility():GetSpecialValueFor("special_shadow_duration") > 0 then
		return false
	end

	if hEntity:GetTeamNumber() == self:GetCaster():GetTeamNumber() then
		return true
	end

	return false
end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_4_modifier_smoke:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:PlayEfxStart(self.ability:GetAOERadius()) end
end

function flea_4_modifier_smoke:OnRefresh(kv)
end

function flea_4_modifier_smoke:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function flea_4_modifier_smoke:PlayEfxStart(radius)
	local string_2 = "particles/fleaman/smoke/fleaman_smoke.vpcf"
	local particle_2 = ParticleManager:CreateParticle(string_2, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(particle_2, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(particle_2, 1, Vector(radius, radius, radius))
	ParticleManager:SetParticleControl(particle_2, 10, Vector(self:GetDuration(), 0, 0))
	self:AddParticle(particle_2, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_Riki.Smoke_Screen.ti8") end
end