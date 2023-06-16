fleaman_u_modifier_smoke = class({})

function fleaman_u_modifier_smoke:IsHidden() return true end
function fleaman_u_modifier_smoke:IsPurgable() return false end

-- AURA -----------------------------------------------------------

-- CONSTRUCTORS -----------------------------------------------------------

function fleaman_u_modifier_smoke:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	if IsServer() then self:PlayEfxStart(self.ability:GetAOERadius()) end
end

function fleaman_u_modifier_smoke:OnRefresh(kv)
end

function fleaman_u_modifier_smoke:OnRemoved()
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function fleaman_u_modifier_smoke:PlayEfxStart(radius)
	local string_2 = "particles/fleaman/smoke/fleaman_smoke.vpcf"
	local particle_2 = ParticleManager:CreateParticle(string_2, PATTACH_WORLDORIGIN, nil)
	ParticleManager:SetParticleControl(particle_2, 0, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(particle_2, 1, Vector(radius, radius, radius))
	ParticleManager:SetParticleControl(particle_2, 10, Vector(self:GetDuration(), 0, 0))
	self:AddParticle(particle_2, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_Riki.Smoke_Screen.ti8") end
end