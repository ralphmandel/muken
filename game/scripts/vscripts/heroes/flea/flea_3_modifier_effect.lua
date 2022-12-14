flea_3_modifier_effect = class({})

function flea_3_modifier_effect:IsHidden() return true end
function flea_3_modifier_effect:IsPurgable() return false end

-- CONSTRUCTORS -----------------------------------------------------------

function flea_3_modifier_effect:OnCreated(kv)
    self.caster = self:GetCaster()
    self.parent = self:GetParent()
    self.ability = self:GetAbility()

	self.radius_impact = kv.radius

	if IsServer() then self:PlayEfxStart() end
end

function flea_3_modifier_effect:OnRefresh(kv)
end

function flea_3_modifier_effect:OnRemoved()
	if IsServer() then self.parent:StopSound("Hero_Slark.Pounce.Leash.Immortal") end
end

-- API FUNCTIONS -----------------------------------------------------------

-- UTILS -----------------------------------------------------------

-- EFFECTS -----------------------------------------------------------

function flea_3_modifier_effect:PlayEfxStart()
	local particle_cast = "particles/econ/items/slark/slark_ti6_blade/slark_ti6_pounce_ground.vpcf"
	local effect_cast = ParticleManager:CreateParticle(particle_cast, PATTACH_WORLDORIGIN, self.caster)
	ParticleManager:SetParticleControlEnt(effect_cast, 0, self.caster, PATTACH_WORLDORIGIN, "attach_hitloc", Vector(0,0,0), true)
	ParticleManager:SetParticleControl(effect_cast, 3, self.parent:GetOrigin())
	ParticleManager:SetParticleControl(effect_cast, 4, Vector(self.radius_impact, 0, 0))
	self:AddParticle(effect_cast, false, false, -1, false, false)

	if IsServer() then self.parent:EmitSound("Hero_Slark.Pounce.Leash.Immortal") end
end